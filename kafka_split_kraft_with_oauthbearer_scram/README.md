# Securing a Split KRaft Kafka Architecture: Setting Up Kerberos and SCRAM Authentication

container to local machine
```bash
127.0.0.1 broker1.dahbest.kfn
127.0.0.1 broker2.dahbest.kfn
127.0.0.1 broker3.dahbest.kfn
127.0.0.1 kerberos.dahbest.kfn

127.0.0.1 kroxy.dahbest.kfn
127.0.0.1 coredns
127.0.0.1 haproxy.dahbest.kfn

127.0.0.1 cluster-a.dahbest.kfn
127.0.0.1 cluster-b.dahbest.kfn

127.0.0.1 cluster-a-1.dahbest.kfn
127.0.0.1 cluster-a-2.dahbest.kfn
127.0.0.1 cluster-a-3.dahbest.kfn
127.0.0.1 cluster-b-1.dahbest.kfn
127.0.0.1 cluster-b-2.dahbest.kfn
127.0.0.1 cluster-b-3.dahbest.kfn
```


```json
DEBUG Completed request:{ 
  "isForwarded":false,
  "requestHeader":{
    "requestApiKey":0,
    "requestApiVersion":13,
    "correlationId":283,
    "clientId":"cagri-producer",
    "requestApiKeyName":"PRODUCE"
  },
  "request":{
    "transactionalId":null,
    "acks":-1,
    "timeoutMs":3000,
    "topicData":[{
      "topicId":"r3IRhpJiTnOM9i0B4tRT5g",
      "partitionData":[{
        "index":8,
        "recordsSizeInBytes":115
      }]
    }]
  },
  "response":{
    "responses":[
        {
        "topicId":"r3IRhpJiTnOM9i0B4tRT5g",
        "partitionResponses":[
          {"index":8,
          "errorCode":0,
          "baseOffset":72,
          "logAppendTimeMs":-1,
          "logStartOffset":0,
          "recordErrors":[],
          "errorMessage":null
          }
          ]
        }],
        "throttleTimeMs":0
    },
  "connection":"172.80.0.11:9092-172.80.0.43:52486-0-4",
  "totalTimeMs":4.67,
  "requestQueueTimeMs":0.118,
  "localTimeMs":2.304,
  "remoteTimeMs":2.109,
  "throttleTimeMs":0,
  "responseQueueTimeMs":0.031,
  "sendTimeMs":0.106,
  "securityProtocol":"SASL_SSL",
  "principal":"User:kafka-admin",
  "listener":"BROKER",
  "clientInformation":{
    "softwareName":"apache-kafka-java",
    "softwareVersion":"4.2.0"
    }
} 
  (kafka.request.logger)
```