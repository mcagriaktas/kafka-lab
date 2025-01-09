# Kafka-Connector Couchbase Example

This project demonstrates how to set up a data pipeline between Apache Kafka and Couchbase using the Kafka Connect Couchbase Connector. The setup includes a multi-node Kafka cluster, Kafka Connect, and Couchbase server running in Docker containers.

## Components

- Couchbase Server (7.6.4)
- Apache Kafka (3 nodes)
- Kafka Connect with Couchbase Connector
- Kafka UI for monitoring

### Couchbase Configuration
| Parameter | Value |
|-----------|-------|
| IP Address | 172.80.0.15 |
| Port | 8091 |
| Username | cagri |
| Password | 35413541 |
| Bucket Name | cagri-bucket |
| Bucket Type | couchbase |
| Bucket RAM Size | 100MB |
| Bucket Replicas | 1 |
| UI URL | http://localhost:8091 |

### Kafka Configuration
| Parameter | Value |
|-----------|-------|
| Kafka 1 | localhost:19092 (external) / localhost:9192 (internal) |
| Kafka 2 | localhost:29092 (external) / localhost:9292 (internal) |
| Kafka 3 | localhost:39092 (external) / localhost:9392 (internal) |
| Topic Name | couchbase-topic |
| Replications | 3 |
| Partitions | 3 |
| UI URL | http://localhost:8080 |

### Kafka Connect Configuration
| Parameter | Value |
|-----------|-------|
| Connect URL | http://localhost:8083 |
| Connector Name | couchbase-sink |
| Connector Class | com.couchbase.connect.kafka.CouchbaseSinkConnector |
| Tasks Max | 1 |
| Document ID Path | /id |
| Collection | _default._default |

### Network Configuration
| Service | Container Name | Internal Port | External Port |
|---------|---------------|---------------|---------------|
| Couchbase | couchbase | 8091-8096 | 8091-8096 |
| | | 11210-11211 | 11210-11211 |
| Kafka 1 | kafka1 | 9192 | 19092 |
| Kafka 2 | kafka2 | 9292 | 29092 |
| Kafka 3 | kafka3 | 9392 | 39092 |
| Kafka Connect | kafka-connector | 8083 | 8083 |
| Kafka UI | kafka-ui | 8080 | 8080 |

## Start the Environment
### Test Couchbase connection
```bash
docker exec -it couchbase couchbase-cli cluster-init \
    --cluster 172.80.0.15 \
    --cluster-username cagri \
    --cluster-password 35413541
```

### Create Bucket 
```bash
docker exec -it couchbase couchbase-cli bucket-create \
    --cluster 172.80.0.15 \
    --username cagri \
    --password 35413541 \
    --bucket cagri-bucket \
    --bucket-type couchbase \
    --bucket-ramsize 100 \
    --bucket-replica 1 \
    --bucket-eviction-policy valueOnly \
    --enable-flush 1 \
    --compression-mode passive
```

### Check bucket configurations
```bash
docker exec -it kafka1 /kafka/bin/kafka-topics.sh \
    --create \
    --bootstrap-server localhost:9192 \
    --replication-factor 3 \
    --partitions 3 \
    --topic couchbase-topic
```

### Create Kafka Topic
```bash
docker exec -it kafka1 /kafka/bin/kafka-topics.sh \
  --create \
  --bootstrap-server localhost:9192 \
  --replication-factor 3 \
  --partitions 3 \
  --topic couchbase-topic
```

### Create Kafka-Connector Source:
```bash
curl -X PUT http://localhost:8083/connectors/couchbase-sink/config -H "Content-Type: application/json" -d '{
    "connector.class": "com.couchbase.connect.kafka.CouchbaseSinkConnector",
    "tasks.max": "1",
    "topics": "couchbase-topic",
    "couchbase.seed.nodes": "172.80.0.15",
    "couchbase.bucket": "cagri-bucket",
    "couchbase.username": "cagri",
    "couchbase.password": "35413541",
    "key.converter": "org.apache.kafka.connect.storage.StringConverter",
    "value.converter": "org.apache.kafka.connect.json.JsonConverter",
    "value.converter.schemas.enable": false,
    "couchbase.document.id": "/id",
    "couchbase.collection": "_default._default"
}'
```

### Check your Kafka-Connector:
```bash
curl -X GET http://localhost:8083/connectors/couchbase-sink/status
```

### Insert Example Data
```bash
docker exec -it kafka1 /kafka/bin/kafka-console-producer.sh \
    --bootstrap-server localhost:9192 \
    --topic couchbase-topic
```

```
{"id": "public1", "name": "Public User 1", "age": 25}
{"id": "public2", "name": "Public User 2", "age": 30}
{"id": "public3", "name": "Public User 3", "age": 35}
{"id": "public4", "name": "Public User 4", "age": 40}
```

### Check the Example of Data:
```bash
./kafka-console-consumer.sh \
  --bootstrap-server localhost:9192 \
  --topic couchbase-topic \
  --from-beginning
```

### Check the Items Counts:
```bash
docker exec -it couchbase cbq -u cagri -p 35413541

\CONNECT couchbase://172.80.0.15;

SELECT * FROM `cagri-bucket`;
```