<center> <h1>A sample chaincode for V1.0 basic testing</h1> </center>
(A sample chaincode with crypto operations like encrypt/decrypt added for some performance testing)


**Credits**: Referred Murali's content from [here](https://github.com/hyperledger/fabric/blob/master/docs/channel-setup.md)

Make sure you cloned this chaincode, the following instructions (for Vagrant environment) requires this chaincode.
(You can use your own chaincode though, make sure to construct the parameters)
```
cd <dir-where-fabric-cloned>/fabric/examples/chaincode/go

mkdir chaincode_sample

curl -O https://raw.githubusercontent.com/asararatnakar/chaincode_sample/master/examples/chaincode/go/chaincode_sample/chaincode_sample.go
```

###1) Vagrant Environment using default channel "testchainid" (Using native binaries)
```
cd /opt/gopath/src/github.com/hyperledger/fabric
make native
```
 Vagrant window 1 - **start orderer**
```
ORDERER_GENERAL_LOGLEVEL=debug orderer
```
where **myc1.block** is the block that was received from the orderer from the create channel command.

Vagrant window 2 - start the peer with default chainid **testchainid**
```
peer node start
```
Vagrant window 3 - Deploy (Install/Instantiate), Invoke and Query
####Deploy chaincode
deploying chaincode is a two step process
1) **Install** & 
2) **Instantiate**

####Install
```
peer chaincode install -n mycc -v 1.0 -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_sample
```

####Instantiate
```
peer chaincode instantiate -C testchainid -n mycc -v 1.0 -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_sample -c '{"Args":[""]}'
```

####Invoke
```
peer chaincode invoke -C testchainid -n mycc -c '{"function":"invoke","Args":["put","a","yugfoiuehyorye87y4yiushdofhjfjdsfjshdfsdkfsdifsdpiupisupoirusoiuou"]}'
```

####Query
```
peer chaincode query -C testchainid -n mycc -c '{"function":"invoke","Args":["get","a"]}'
```
###2) Vagrant Environment NON Default chainid(Using native binaries)
```
vagrant ssh
```
Make sure you clear the folder `/var/hyperledger/` after each run
```
rm -rf /var/hyperledger/*
```
Execute following commands from fabric
```
cd /opt/gopath/src/github.com/hyperledger/fabric
```

Build the executables orderer and peer with `make native` command
 

Vagrant window 1 - **start orderer**
```
ORDERER_GENERAL_LOGLEVEL=debug orderer
```

####Create a channel
Vagrant window 2 - ask orderer to **create a chain**

```
peer channel create -c myc1
```

On successful creation, a genesis block **myc1.block** is saved in current directory

####Join channel
Vagrant window 3 - start the peer in a _**"chainless"**_ mode
```
peer node start --peer-defaultchain=false
```

Vagrant window 2 - peer to join a channel
```
peer channel join -b myc1.block
```

where **myc1.block** is the block that was received from the orderer from the create channel command.


####Deploy chaincode
Chaincode dpeloy is a two step process
1) **Install** & 
2) **Instantiate**

####Install
```
peer chaincode install -n mycc -v 1.0 -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_sample
```

####Instantiate
```
peer chaincode instantiate -C myc1 -n mycc -v 1.0 -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_sample -c '{"Args":[""]}'
```

####Invoke
```
peer chaincode invoke -C myc1 -n mycc -c '{"function":"invoke","Args":["put","a","yugfoiuehyorye87y4yiushdofhjfjdsfjshdfsdkfsdifsdpiupisupoirusoiuou"]}'
```
**NOTE** wait for few seconds

####Query
```
peer chaincode query -C myc1 -n mycc -c '{"function":"invoke","Args":["get","a"]}'
```

###3) Using Docker Images
Clone fabric repo and this repo
```
git clone https://github.com/hyperledger/fabric.git
cd fabric
```
Generate docker-images
```
make docker
```
Upon success you should see will see all the images similar to below

```
$ docker images
REPOSITORY                     TAG                             IMAGE ID            CREATED             SIZE
hyperledger/fabric-kafka       latest                          c9e9b89fa0e2        3 hours ago         1.3 GB
hyperledger/fabric-kafka       x86_64-0.7.0-snapshot-2c8bcf0   c9e9b89fa0e2        3 hours ago         1.3 GB
hyperledger/fabric-zookeeper   latest                          b13a2744b76a        3 hours ago         1.31 GB
hyperledger/fabric-zookeeper   x86_64-0.7.0-snapshot-2c8bcf0   b13a2744b76a        3 hours ago         1.31 GB
hyperledger/fabric-testenv     latest                          325b6cfa2a11        3 hours ago         1.39 GB
hyperledger/fabric-testenv     x86_64-0.7.0-snapshot-2c8bcf0   325b6cfa2a11        3 hours ago         1.39 GB
hyperledger/fabric-orderer     latest                          0743df66ddd1        3 hours ago         179 MB
hyperledger/fabric-orderer     x86_64-0.7.0-snapshot-2c8bcf0   0743df66ddd1        3 hours ago         179 MB
hyperledger/fabric-peer        latest                          cec5da3b2e68        3 hours ago         183 MB
hyperledger/fabric-peer        x86_64-0.7.0-snapshot-2c8bcf0   cec5da3b2e68        3 hours ago         183 MB
hyperledger/fabric-javaenv     latest                          fbc9ceda5166        3 hours ago         1.42 GB
hyperledger/fabric-javaenv     x86_64-0.7.0-snapshot-2c8bcf0   fbc9ceda5166        3 hours ago         1.42 GB
hyperledger/fabric-ccenv       latest                          5f296d780c1d        3 hours ago         1.29 GB
hyperledger/fabric-ccenv       x86_64-0.7.0-snapshot-2c8bcf0   5f296d780c1d        3 hours ago         1.29 GB
hyperledger/fabric-ca          latest                          e9f3e1aff06c        12 days ago         184 MB
hyperledger/fabric-baseimage   x86_64-0.3.0                    f4751a503f02        2 weeks ago         1.27 GB
hyperledger/fabric-baseos      x86_64-0.3.0                    c3a4cf3b3350        2 weeks ago         161 MB

```
clone ths repo

```
git clone https://github.com/asararatnakar/chaincode_sample.git

cd chaincode_sample
```

spin the network using docker-compose file

```
docker-compose up -d
```

You must see 5 containers (**_solo orderer_**, 3 **_peers_** and one **_cli_** container) as below
```
CONTAINER ID        IMAGE                        COMMAND                  CREATED              STATUS              PORTS                                            NAMES
bb4c16656b8b        hyperledger/fabric-peer      "sh -c './script.s..."   About a minute ago   Up About a minute                                                    cli
58aca57f193b        hyperledger/fabric-peer      "peer node start -..."   About a minute ago   Up About a minute   0.0.0.0:9051->7051/tcp, 0.0.0.0:9053->7053/tcp   peer2
097d338f6178        hyperledger/fabric-peer      "peer node start -..."   About a minute ago   Up About a minute   0.0.0.0:8051->7051/tcp, 0.0.0.0:8053->7053/tcp   peer1
530e4e7492de        hyperledger/fabric-peer      "peer node start -..."   About a minute ago   Up About a minute   0.0.0.0:7051->7051/tcp, 0.0.0.0:7053->7053/tcp   peer0
5bfd502d5551        hyperledger/fabric-orderer   "orderer"                About a minute ago   Up About a minute   0.0.0.0:7050->7050/tcp                           orderer
```

### How to create a channel and join the peer to the channel

A shellscript **script.sh** is baked inside the cli conatiner, The script will do the below things for you:

* _Creates a channel_ **myc1** with Anchor Peer as peer0 (a text file with Peer0 IP, HOST and Signed Certificate)

* peer0, peer1 and peer2 will **Join** the channel

* **Install** chaincode *chaincode_sample* remotely onto peer0

* **Instantiate**s your chaincode (At this point you will see a seperate container **_peer0-peer0-mycc-1.0_**)

* **Invoke** chaincode (a key with value of interested random payload) - wait for few secs

* **Query** chaincode, must show the value stored with above transaction

#### How to see the above actions ?
check the cli docker container logs
```
docker logs -f cli
```

At the end of the result you will see something like below:
```
2017-02-18 04:29:11.213 UTC [main] main -> INFO 009 Exiting.....
2017-02-18 04:29:21.250 UTC [logging] InitFromViper -> DEBU 001 Setting default logging level to DEBUG for command 'chaincode'
2017-02-18 04:29:21.251 UTC [msp] GetLocalMSP -> DEBU 002 Returning existing local MSP
2017-02-18 04:29:21.251 UTC [msp] GetDefaultSigningIdentity -> DEBU 003 Obtaining default signing identity
2017-02-18 04:29:21.251 UTC [msp] Sign -> DEBU 004 Sign: plaintext: 0A80080A38080322046D7963312A2432...0A06696E766F6B650A036765740A0161 
2017-02-18 04:29:21.252 UTC [msp] Sign -> DEBU 005 Sign: digest: 150C43DE54051AD0F0673B0E21824C08D142FDA1175F255965DB6A915F5B848E 
Query Result: yugfoiuehyorye87y4yiushdofhjfjdsfjshdfsdkfsdifsdpiupisupoirusoiuou
2017-02-18 04:29:21.257 UTC [main] main -> INFO 006 Exiting.....
```

#### How can I see chaincode logs ?
After chaincode **Instantiate** you will see a container **_peer0-peer0-mycc-1.0_**, docker logs for this container will provide chaincode logs

```
docker logs -f peer0-peer0-mycc-1.0 
```

```
Instantiate chaincode 

Invoke chaincode
----- Write Transaction -----
a ==> "yugfoiuehyorye87y4yiushdofhjfjdsfjshdfsdkfsdifsdpiupisupoirusoiuou" 

Query Chaincode
------ Read Transaction -----
a ==> "yugfoiuehyorye87y4yiushdofhjfjdsfjshdfsdkfsdifsdpiupisupoirusoiuou" 

```

## How do I create my own channel and join the peers of my interest

These commands are already part of the **script.sh**, below commands are for your reference

####Anchor peer
Change PEER IP , PORT and Signed certificate (cert info will be available under  **_crypto/peer1/signcerts/peer1Signer.pem_** for peer1)

```
cat<<EOF>anchorPeer1.txt
172.17.0.4
8051
-----BEGIN CERTIFICATE-----
MIIBCzCBsgICA+gwCgYIKoZIzj0EAwIwEzERMA8GA1UEAwwIcGVlck9yZzAwHhcN
MTcwMTI0MTk1NTQ1WhcNMTgwMTI0MTk1NTQ1WjAQMQ4wDAYDVQQDDAVwZWVyMTBZ
MBMGByqGSM49AgEGCCqGSM49AwEHA0IABJGk171VnjV2dmpKsuKEzJudLJ5CXtfU
Q7pq6rsm5xMowNA4BXTjSc2CGsU7ZOXFDl680ur1vav3zeZ6YBtGSWIwCgYIKoZI
zj0EAwIDSAAwRQIhAJuKIZlHgSPK2x11Al+QeUhy+RbVX0VA0PzBr5UVzUDtAiB/
DXz3BdQwd20X/p6QSoCqA+sUoP3SQOhfEvbSzuPC9g==
-----END CERTIFICATE-----
EOF
```

####Create channel

Give what ever channel that you want to create here
```
CORE_PEER_GOSSIP_IGNORESECURITY=true CORE_PEER_COMMITTER_LEDGER_ORDERER=orderer:7050 peer channel create -c mychannel -a anchorPeer1.txt
```

####Join channel

Join peers of your intrest
```
CORE_PEER_COMMITTER_LEDGER_ORDERER=orderer:7050 CORE_PEER_ADDRESS=peer1:7051 peer channel join -b mychannel.block
```

####Install chaincode remotely
Installing chaincode onto peer1
```
CORE_PEER_COMMITTER_LEDGER_ORDERER=orderer:7050 CORE_PEER_ADDRESS=peer1:7051 peer chaincode install -n mycc1 -v 1.0 -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_sample 
```

####Instantiate chaincode
Instantiate chaincode, this will launch a chaincode container
```
CORE_PEER_COMMITTER_LEDGER_ORDERER=orderer:7050 CORE_PEER_ADDRESS=peer1:7051 peer chaincode instantiate -C mychannel -n mycc1 -v 1.0 -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_sample -c '{"Args":[""]}'
```

####Invoke chaincode

```
CORE_PEER_COMMITTER_LEDGER_ORDERER=orderer:7050 CORE_PEER_ADDRESS=peer1:7051 peer chaincode invoke -C mychannel -n mycc1 -c '{"function":"invoke","Args":["put","a","yugfoiuehyorye87y4yiushdofhjfjdsfjshdfsdkfsdifsdpiupisupoirusoiuou"]}'
```

**NOTE** Make sure you wait for few seconds

####Query chaincode

```
CORE_PEER_COMMITTER_LEDGER_ORDERER=orderer:7050 CORE_PEER_ADDRESS=peer1:7051 peer chaincode query -C mychannel -n mycc1 -c '{"function":"invoke","Args":["get","a"]}'
```
The result of the above command should be as below

```
Query Result: yugfoiuehyorye87y4yiushdofhjfjdsfjshdfsdkfsdifsdpiupisupoirusoiuou
```
