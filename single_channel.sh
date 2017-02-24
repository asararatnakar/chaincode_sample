#!/bin/sh

# find address of orderer and peers in your network
ORDERER_IP=`perl -e 'use Socket; $a = inet_ntoa(inet_aton("orderer")); print "$a\n";'`
PEER0_IP=`perl -e 'use Socket; $a = inet_ntoa(inet_aton("peer0")); print "$a\n";'`
PEER1_IP=`perl -e 'use Socket; $a = inet_ntoa(inet_aton("peer1")); print "$a\n";'`
PEER2_IP=`perl -e 'use Socket; $a = inet_ntoa(inet_aton("peer2")); print "$a\n";'`
PEER3_IP=`perl -e 'use Socket; $a = inet_ntoa(inet_aton("peer2")); print "$a\n";'`

echo "-----------------------------------------"
echo "Ordere IP $ORDERER_IP"
echo "PEER0 IP $PEER0_IP"
echo "PEER1 IP $PEER1_IP"
echo "PEER2 IP $PEER2_IP"
echo "PEER2 IP $PEER3_IP"
echo "-----------------------------------------"

CORE_PEER_GOSSIP_IGNORESECURITY=true
CORE_PEER_COMMITTER_LEDGER_ORDERER=$ORDERER_IP:7050
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/chaincode_sample/crypto/peer/peer0/localMspConfig
CORE_PEER_ADDRESS=$PEER0_IP:7051
CORE_PEER_LOCALMSPID=Org0MSP

verifyResult () {
	if [ $1 -ne 0 ]; then
		echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
   		echo "========== ERROR !!! Please check peer logs to verify the issue ==========="
   		echo "===================== FAILURED to execute E2E Scenario ====================="
   		exit 1
	fi
}

###TODO: Add checks for the results
peer channel create -c myc1 -f channel.tx>log.txt 2>&1 
res=$?
cat log.txt
verifyResult $res "Channel creation failed"

echo "===================== channel \"myc1\" is created successfully ===================== "
echo
#peer channel join -b myc1.block >log.txt 2>&1
#cat log.txt
#ORDERER_GENERAL_LOCALMSPDIR=/opt/gopath/src/github.com/hyperledger/fabric/chaincode_sample/crypto/peer/peer1/localMspConfig
for ch in 0 1 2 3; do
	CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/chaincode_sample/crypto/peer/peer$ch/localMspConfig
	CORE_PEER_ADDRESS=peer$ch:7051
	CORE_PEER_LOCALMSPID="Org"$ch"MSP"
	peer channel join -b myc1.block >log.txt 2>&1
	res=$?
	cat log.txt
        verifyResult $res "Peer$ch is unable to Join Channel"
	echo "===================== peer$ch joined on the channel \"myc1\" ===================== "
done

for ch in 0 1; do
	CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/chaincode_sample/crypto/peer/peer$ch/localMspConfig
	CORE_PEER_ADDRESS=peer$ch:7051
	CORE_PEER_LOCALMSPID="Org"$ch"MSP"
	peer chaincode install -n mycc -v 1.0 -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_sample >log.txt 2>&1
	res=$?
	cat log.txt
        verifyResult $res "Chaincode installation on remote peer PEER$ch is Failed"
	echo "===================== Chaincode is installed on remote peer PEER$ch ===================== "
done
#CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/chaincode_sample/crypto/peer/peer0/localMspConfig
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/chaincode_sample/crypto/peer/peer1/localMspConfig
CORE_PEER_ADDRESS=$PEER1_IP:7051
CORE_PEER_LOCALMSPID=Org1MSP
peer chaincode instantiate -C myc1 -n mycc -v 1.0 -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_sample -c '{"Args":[""]}' -P "OR('Org0MSP.member','Org1MSP.member','Org2MSP.member','Org3MSP.member')" >log.txt 2>&1 
#-P "OR('Org0MSP.member','Org1MSP.member')" >log.txt 2>&1
res=$?
cat log.txt
verifyResult $res "Chaincode instantiation failed"

echo "===================== chaincode Instantiation on PEER0 is successful ===================== "
sleep 15

#CORE_PEER_COMMITTER_LEDGER_ORDERER=$ORDERER_IP:7050 CORE_PEER_ADDRESS=$PEER0_IP:7051 
peer chaincode invoke -C myc1 -n mycc -c '{"function":"invoke","Args":["put","a","yugfoiuehyorye87y4yiushdofhjfjdsfjshdfsdkfsdifsdpiupisupoirusoiuou"]}' >log.txt 2>&1
res=$?
cat log.txt
verifyResult $res "Invoke execution on PEER$ch failed "
echo "===================== Invoke transaction on chaincode===================== "
sleep 15

#CORE_PEER_COMMITTER_LEDGER_ORDERER=$ORDERER_IP:7050 CORE_PEER_ADDRESS=$PEER0_IP:7051 
peer chaincode query -C myc1 -n mycc -c '{"function":"invoke","Args":["get","a"]}' >log.txt 2>&1
res=$?
cat log.txt
verifyResult $res "Query execution on PEER$ch failed "
grep -q "yugfoiuehyorye87y4yiushdofhjfjdsfjshdfsdkfsdifsdpiupisupoirusoiuou" log.txt
verifyResult $? "Query result on PEER$ch INVALID "

echo "===================== Query on chaincode on PEER0 is successful ===================== "
echo "===================== ALL GOOD , E2E Test execution completed ===================== "
exit 0
