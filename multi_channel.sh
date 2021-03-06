#!/bin/sh
#### DONOT USE THIS YET
# find address of orderer and peers in your network
ORDERER_IP=`perl -e 'use Socket; $a = inet_ntoa(inet_aton("orderer")); print "$a\n";'`
PEER0_IP=`perl -e 'use Socket; $a = inet_ntoa(inet_aton("peer0")); print "$a\n";'`
PEER1_IP=`perl -e 'use Socket; $a = inet_ntoa(inet_aton("peer1")); print "$a\n";'`
PEER2_IP=`perl -e 'use Socket; $a = inet_ntoa(inet_aton("peer2")); print "$a\n";'`
echo "-----------------------------------------"
echo "Ordere IP $ORDERER_IP"
echo "PEER0 IP $PEER0_IP"
echo "PEER1 IP $PEER1_IP"
echo "PEER2 IP $PEER2_IP"
echo "-----------------------------------------"


###TODO: Add checks for the results
for ch in 1 2; do
	CORE_PEER_GOSSIP_IGNORESECURITY=true CORE_PEER_COMMITTER_LEDGER_ORDERER=$ORDERER_IP:7050 peer channel create -c myc$ch  >log.txt 2>&1
	cat log.txt
	echo "===================== channel \"myc$ch\" is created successfully ===================== "
done

for ch in 1 2; do
	for peer in 0 1 2; do
		CORE_PEER_COMMITTER_LEDGER_ORDERER=$ORDERER_IP:7050 CORE_PEER_ADDRESS=peer$peer:7051 peer channel join -b myc$ch.block >log.txt 2>&1
		cat log.txt
	done
	echo "===================== All peers joined on the channel \"myc$ch\" ===================== "
done

for peer in 0 1 2; do
	CORE_PEER_COMMITTER_LEDGER_ORDERER=$ORDERER_IP:7050 CORE_PEER_ADDRESS=peer$peer:7051 peer chaincode install -n mycc -v 1.0 -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_sample >log.txt 2>&1
	cat log.txt
	echo "===================== Chaincode is installed on remote peer PEER$peer ===================== "
done

CORE_PEER_COMMITTER_LEDGER_ORDERER=$ORDERER_IP:7050 CORE_PEER_ADDRESS=$PEER0_IP:7051 peer chaincode instantiate -C myc1 -n mycc -v 1.0 -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_sample -c '{"Args":[""]}' >log.txt 2>&1
cat log.txt
echo "===================== Instantiated chaincode on PEER0 ===================== "
sleep 15

CORE_PEER_COMMITTER_LEDGER_ORDERER=$ORDERER_IP:7050 CORE_PEER_ADDRESS=$PEER1_IP:7051 peer chaincode invoke -C myc1 -n mycc -c '{"function":"invoke","Args":["put","a","yugfoiuehyorye87y4yiushdofhjfjdsfjshdfsdkfsdifsdpiupisupoirusoiuou"]}' >log.txt 2>&1
cat log.txt
echo "===================== Invoke transaction on chaincode===================== "
sleep 15

for ch in 1 2; do
CORE_PEER_COMMITTER_LEDGER_ORDERER=$ORDERER_IP:7050 CORE_PEER_ADDRESS=$PEER2_IP:7051 peer chaincode query -C myc$ch -n mycc -c '{"function":"invoke","Args":["get","a"]}' >log.txt 2>&1
cat log.txt
echo "===================== Query on PEER2 on channel \"myc$ch\" ===================== "
done

echo "===================== Multi Channel Test execution completed ===================== "
