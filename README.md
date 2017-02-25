<center> <h1>A sample chaincode for V1.0 basic testing</h1> </center>
(A sample chaincode with crypto operations like encrypt/decrypt added for some performance testing)


**Credits**: Referred Murali's content from [here](https://github.com/hyperledger/fabric/blob/master/docs/channel-setup.md)

###Important !!!
This has been verified on commit level **ae65a02e42aa4ef227d4ecfa50115238e3f91b03** 

```
	git reset --hard ae65a02e42aa4ef227d4ecfa50115238e3f91b03
```

Following instructions (for Vagrant environment) requires sample chaincode from this repo, Make sure you cloned the chaincode
(You can use your own chaincode though, make sure you pass the right arguments)
```
cd <dir-where-fabric-cloned>/fabric/examples/chaincode/go

mkdir chaincode_sample

curl -O https://raw.githubusercontent.com/asararatnakar/chaincode_sample/master/examples/chaincode/go/chaincode_sample/chaincode_sample.go
```

###1) Vagrant Environment NON Default chainid(Using native binaries)
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

###2) Using Docker Images
Clone fabric repo and this repo
```
git clone https://github.com/hyperledger/fabric.git
cd fabric
```
!!!!! **IMPORTANT** !!!!!
### Pre-reqs
Verified on the commit level : **2fc6bc606bc5f732d9b04ce28e1d28dfbd220173**

Cherry pick below patches for End2End Scenario to work (as of today Feb23, 11 pm)
```
https://gerrit.hyperledger.org/r/#/c/6379
https://gerrit.hyperledger.org/r/#/c/5955
```

* Generate all **org certs** using behave.
```
cd fabric/bddtests
behave -k -D cache-deployment-spec features/bootstrap.feature
```
* Use awesome tool **configtxgen**  to create fabric channel configuration transaction and orderer bootstrap block.More details [here](https://github.com/hyperledger/fabric/blob/master/docs/configtxgen.md)
Also refer the configtx.yaml available in this repo.

```
make configtxgen
configtxgen -profile TwoOrgs -outputCreateChannelTx channel.tx -outputBlock orderer.block -channelID myc1;
```


Generate docker-images
```
make docker
```
Upon success you will see all the images similar to below

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

A shellscript **single_channel.sh** is baked inside the cli conatiner, The script will do the below things for you:

* _Creates a channel_ **myc1** with configuration transaction generated using configtxgen tool **channelTx** (this is already mounted to cli container)

    As a result of this command **myc1.block** will get created on the file system

* peer0 from **peerOrg0** ) will **Join** the channel

* **Install** chaincode *chaincode_sample*  on a remote **peer0**

* **Instantiate**s your chaincode (At this point you will see a seperate container **_peer0-peer0-mycc-1.0_**) also notice there is a Policy specified with **-P**

* **Invoke** chaincode (a key with value of interested random payload) (wait for few secs to complete the tx)

* **Query** chaincode

#### How do I see the above said actions ?
check the cli docker container logs
```
docker logs -f cli
```

At the end of the result you will see something like below:
```
2017-02-24 01:31:53.191 UTC [logging] InitFromViper -> DEBU 001 Setting default logging level to DEBUG for command 'chaincode'
2017-02-24 01:31:53.192 UTC [msp] GetLocalMSP -> DEBU 002 Returning existing local MSP
2017-02-24 01:31:53.192 UTC [msp] GetDefaultSigningIdentity -> DEBU 003 Obtaining default signing identity
2017-02-24 01:31:53.192 UTC [msp] Sign -> DEBU 004 Sign: plaintext: 0A8A050A54080322046D7963312A4032...0A06696E766F6B650A036765740A0161 
2017-02-24 01:31:53.192 UTC [msp] Sign -> DEBU 005 Sign: digest: 2D47DF762A73DC6AA6F39D7332AC1E0EAD0FB53CD8DAB51B1E5F9063193A61F9 
Query Result: yugfoiuehyorye87y4yiushdofhjfjdsfjshdfsdkfsdifsdpiupisupoirusoiuou
2017-02-24 01:31:53.198 UTC [main] main -> INFO 006 Exiting.....
===================== Query on chaincode on PEER0 is successful ===================== 
===================== ALL GOOD , E2E Test execution completed ===================== 
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

## How do I create channel and join the peers of my interest

Commands are available in **single_channel.sh**, 
these commands are to create a channel and join peer1 to the channel, commands are for your reference.

!!! **Important** !!!
I am using  one peer only i.e, **peer1** for join/instantiate/invoke/query, So I fixed some environment variables. you must change these  accordingly for other peers
```
CORE_PEER_COMMITTER_LEDGER_ORDERER=orderer:7050
ORDERER_GENERAL_LOCALMSPDIR=/opt/gopath/src/github.com/hyperledger/fabric/chaincode_sample/crypto/peer/peer1/localMspConfig
CORE_PEER_ADDRESS=$PEER1_IP:7051
CORE_PEER_LOCALMSPID=Org1MSP
```

####Create channel

Specify the name of the channel  with **-c** option and **-f** must be suplied with Channel creation transaction i.e., **channel.tx** (In this case it is **channelTx** , you can mount your own channel txn )
```
 peer channel create -c mychannel -f channel.tx
```

####Join channel

Join peers of your intrest
```
 peer channel join -b mychannel.block
```

####Install chaincode remotely
Installing chaincode onto remote peer **peer1**
```
peer chaincode install -n mycc -v 1.0 -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_sample 
```

####Instantiate chaincode
Instantiate chaincode, this will launch a chaincode container
```
peer chaincode instantiate -C mychannel -n mycc -v 1.0 -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_sample -c '{"Args":[""]}' -P "AND('Org1MSP.member')"
```

**NOTE:** 
* After the above command you will notice a new chaincode container , something like **dev-peer1-mycc-1.0**
* Also notice the Endorsement Policy specified with **-P** option, that needs to be validated by System Chaincode (**VSCC**) , [more details]()

####Invoke chaincode

```
https://github.com/hyperledger/fabric/blob/master/docs/endorsement-policies.md
peer chaincode invoke -C mychannel -n mycc1 -c '{"function":"invoke","Args":["put","a","yugfoiuehyorye87y4yiushdofhjfjdsfjshdfsdkfsdifsdpiupisupoirusoiuou"]}'
```

**NOTE** Make sure you wait for few seconds

####Query chaincode

```
peer chaincode query -C mychannel -n mycc1 -c '{"function":"invoke","Args":["get","a"]}'
```
The result of the above command should be as below

```
Query Result: yugfoiuehyorye87y4yiushdofhjfjdsfjshdfsdkfsdifsdpiupisupoirusoiuou
```

###Troubleshoot

If you are see the below error 
```
Error: Error endorsing chaincode: rpc error: code = 2 desc = Error installing chaincode code mycc:1.0(chaincode /var/hyperledger/production/chaincodes/mycc.1.0 exits)
```

Probably you have the images (ex **_peer0-peer0-mycc-1.0_** or **_peer1-peer0-mycc1-1.0_**) from your prevoous runs
Remove them and retry again. here is a helper command

```
docker rmi -f $(docker images | grep peer[0-9]-peer[0-9] | awk '{print $3}')
```

###Misc
Now you can launch network using a shell script
```
./network_setup up 
```
Default option is to use hyperledger images

If you don't want to build fabric images, you can use my images by supplying the docker-compose file
```
./network_setup up docker-compose-ratnakar.yaml
```

To cleanup the network, use **down**  option with the command
```
./network_setup down
```
