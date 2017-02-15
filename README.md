# chaincode_sample
A sample chaincode with crypto operations like encrypt/decrypt

Credits: referred this from [here](https://github.com/hyperledger/fabric/blob/master/docs/channel-setup.md)

###Using Vagrant
```
vagrant ssh
```

Run all the commands from below directory
```
cd /opt/gopath/src/github.com/hyperledger/fabric
```

Build the executables orderer and peer with `make native` command
 
####Create a channel
Vagrant window 1 - **start orderer**
```
ORDERER_GENERAL_LOGLEVEL=debug orderer
```


Vagrant window 2 - ask orderer to **create a chain**

```
peer channel create -c myc1
```

On successful creation, a genesis block **myc1.block** is saved in current directory

####Join channel
Vagrant window 3 - start the peer in a "chainless" mode
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

```
peer chaincode install -C myc1 -n mycc -v 1.0 -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_sample

peer chaincode instantiate -C myc1 -n mycc -v 1.0 -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_sample -c '{"Args":[""]}'
```

####Invoke
```
peer chaincode invoke -C peer chaincode invoke -C testchainid -n mycc -c '{"Args":["put","a","yugfoiuehyorye87y4yiushdofhjfjdsfjshdfsdkfsdifsdpiupisupoirusoiuou"]}'
```

####Query
```
peer chaincode query -C testchainid -n mycc -c '{"Args":["query","a"]}'
```

### Using Docker-compose
Clone fabric repo
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
$ doker imagesfa
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

go to docs folder

```
cd fabric/docs
```

Use the avilable docker-compose file:

```
docker-compose -f docker-compose-channel.yml up -d
```

This should create below containers (solo orderer, peer and cli container)
```
CONTAINER ID        IMAGE                        COMMAND                  CREATED             STATUS              PORTS                                            NAMES
63fc483300bd        hyperledger/fabric-peer      "/bin/sh"                2 minutes ago       Up 2 minutes                                                         cli
01a2846b9f12        hyperledger/fabric-peer      "peer node start -..."   2 minutes ago       Up 2 minutes        0.0.0.0:7051->7051/tcp, 0.0.0.0:7053->7053/tcp   peer0
4850f6e875dc        hyperledger/fabric-orderer   "orderer"                2 minutes ago       Up 2 minutes        0.0.0.0:5005->5005/tcp, 7050/tcp                 orderer
```

####Now Its' time to create a channel and join the peer to the channel 
(Don't yell yet me,.... I gotta try with multiple peers my self yet)

start/execute **CLI container**
```
docker exec -it cli bash
```
#####Create channel
And ask orderer to create a channel for you

```
CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/msp/sampleconfig CORE_PEER_COMMITTER_LEDGER_ORDERER=orderer:5005 peer channel create -c myc1
```

On successful creation, a genesis block **myc1.block** is saved in current directory. 
where **myc1.block** is the block that was received from the orderer from the create channel command.

#####Join channel
Execute the join command to peer0 in the CLI container.

```
CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/fabric/msp/sampleconfig CORE_PEER_COMMITTER_LEDGER_ORDERER=orderer:5005 CORE_PEER_ADDRESS=peer0:7051  peer channel join -b myc1.block
```



####Deploy
####1. Install chaincode on peer0

Go to peer0 with GOPATH set
```
docker exec -e GOPATH=/opt/gopath -it peer0 bash
```
execute the **install** command on peer0

```
CORE_PEER_ADDRESS=peer0:7051 CORE_PEER_COMMITTER_LEDGER_ORDERER=orderer:5005 peer chaincode install -C myc1 -n mycc -v 1.0 -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_sample

```

Exit the peer0 container:
```
exit
```

####2. Instantiate chaincode from CLI container

Enter CLI cntainer
```
docker exec -it cli bash
```
Execute **instantiate** command from shell
(**TODO**: Check if version can be omitted here ? )
```
CORE_PEER_ADDRESS=peer0:7051 CORE_PEER_COMMITTER_LEDGER_ORDERER=orderer:5005 peer chaincode instantiate -C myc1 -n mycc -v 1.0 -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_sample -c '{"Args":["init",""]}'
```

####3. Invoke:

Continue executing these commands on the CLI container
```
peer chaincode invoke -C myc1 -n mycc -c '{"Args":["put","a","8qewiuyeiwqe9ijcknx,mcn,mxzn987098709870987987097098709870"]}'
```

####4. Query:

Continue executing these commands on the CLI container

```
peer chaincode query -C myc1 -n mycc -c '{"Args":["get","a"]}'
```
Query result will be shown after executing the above command
```
Query Result: 8qewiuyeiwqe9ijcknx,mcn,mxzn987098709870987987097098709870
```
