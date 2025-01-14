# Kafka Upgrade Guide:

This documentation details upgrading Kafka from 3.1.0 to 3.8.0, focusing on maintaining compatibility using inter.broker.protocol.version and log.message.format.version. For ZooKeeper mode, you start by setting these to 3.1 to ensure backward compatibility, then gradually update them to 3.8. In KRaft mode, similar settings allow a seamless transition, preserving data integrity and compatibility throughout the upgrade process. Each step verifies that topics and data remain accessible, ensuring a smooth upgrade without disruption.

## Prerequisites

**Notes:**
- Versions 2.8.0 to 3.5.x: Both ZooKeeper and KRaft are supported.
- Version 3.5.x and beyond: ZooKeeper is deprecated, and KRaft is the only supported mode.
- Version 4.0.0 and later: ZooKeeper is completely removed, and only KRaft mode is available.

### Kafka and Zookeeper Version:
| Component          | Version |
|--------------------|---------|
| new_kafka          | 3.8.0   |
| old_kafka          | 3.1.0   |
| Zookeeper          | 3.7.2   |

- Docker and Docker Compose installed
- Basic understanding of Apache Kafka
- Sufficient disk space for logs and data

## Quick Start

### Pull The kafka-migrate-upgrade-test Container (Optional)

```bash
services:
  kafka:
    images: mucagriaktas/kafka-demo-container:v1
    container_name: kafka
    stdin_open: true
    tty: true   
    volumes:
      - ./home/config:/mnt/config
    command: /bin/bash
```

Check the readme in DockerHub: [https://hub.docker.com/repository/docker/mucagriaktas/kafka-migration-test/general](https://hub.docker.com/repository/docker/mucagriaktas/kafka-migration-test/general)

1. Start the ubuntu (kafka) container:
```bash
docker-compose up -d --build
```

2. Access the container:
```bash
docker exec -it kafka bash
```

3. You can find all kafka and zookeeper files in:
```bash
cd /mnt
```

**Note**: In this demo, we'll use two metrics during the upgrade process. While some versions may not require these metrics, differences in metadata protocols across versions necessitate their use for security purposes.

```
inter.broker.protocol.version=x.y
log.message.format.version=x.y
```

## Upgrade Zookeeper Version Kafka 3.1.0 to Kafka 3.8.0

**Note**: This documentation follows a single broker. If you're running multiple brokers, the process is the same; just ensure every broker has the same `server.properties`.

### ZooKeeper Configuration (3.7.2)
Create and configure `zoo.cfg` (`/mnt/apache-zookeeper-3.7.2-bin/conf/zoo.cfg`):

```bash
tickTime=2000
dataDir=/home/ubuntu/zookeeper_data
clientPort=2181
initLimit=10
syncLimit=5
```

### Start ZooKeeper:

```bash
/mnt/apache-zookeeper-3.7.2-bin/bin/zkServer.sh start
```

### Add These Config Lines in server.properties:
`The file in the /mnt/config/kafka_3_1_0/zoo_server.properties`

```bash
log.dirs=/home/ubuntu/logs/kafka

inter.broker.protocol.version=3.1
log.message.format.version=3.1
```

### Start Kafka 3.1.0:

```bash
/mnt/kafka_2.13-3.1.0/bin/kafka-server-start.sh /mnt/config/kafka_3_1_0/zoo_server.properties
```

### Create Sample Data:

```bash
/mnt/kafka_2.13-3.1.0/bin/kafka-console-producer.sh --bootstrap-server localhost:9092 --topic cagri
```

```bash
# Output
> 1
> 2
> 3
```

### Read Sample Data to Ensure:

```bash
/mnt/kafka_2.13-3.1.0/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic cagri --from-beginning
```

```bash
# Output
1
2
3
```

### Download and Install Kafka 3.8.0:
The container already have the kafka version check:

```bash
cd /mnt
```

### Copy Existing server.properties to Replace 3.8.0 server.properties:

```bash
# Your log path must match the one specified in the old server.properties file.
log.dirs=/home/ubuntu/logs/kafka

# Don't make any changes when starting your cluster for the first time.
inter.broker.protocol.version=3.1 
log.message.format.version=3.1
```

### Stop Kafka 3.1.0:

```bash
# Either press Ctrl+C or
/mnt/kafka_2.13-3.1.0/bin/kafka-server-stop.sh
```

### Start Kafka 3.8.0:

```bash
/mnt/kafka_2.13-3.8.0/bin/kafka-server-start.sh /mnt/config/kafka_3_8_0/zoo_server.properties
```

### Check Topics:

```bash
./kafka-topics.sh --bootstrap-server localhost:9092 --list
```

```bash
# Output
__consumer_offsets
cagri
```

### Verify Data:
```bash
./kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic cagri --from-beginning
```

```bash
# Output
1
2
3
```

### Wait for synchronization to complete, then update the server.properties file.

```bash
# Your log path must match the one specified in the old server.properties file.
log.dirs=/home/ubuntu/logs/kafka

inter.broker.protocol.version=3.8 
log.message.format.version=3.8
```

### Stop Kafka 3.8.0:

```bash
# Either press Ctrl+C or
/mnt/kafka_2.13-3.8.0/bin/kafka-server-stop.sh
```

### Start Kafka 3.8.0 Again:

```bash
/mnt/kafka_2.13-3.8.0/bin/kafka-server-start.sh /mnt/config/kafka3_8_0/zoo_server.properties
```

### Check Topics:

```bash
./kafka-topics.sh --bootstrap-server localhost:9092 --list
```

```bash
# Output
__consumer_offsets
cagri
```

### Verify Data:

```bash
./kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic cagri --from-beginning
```

```bash
# Output
1
2
3
```

## Upgrade KRaft Version Kafka 3.1.0 to Kafka 3.8.0

### Add These Config Lines in server.properties:
`The file in the /mnt/config/kafka_3_1_0/kraft_server.properties`

```bash
log.dirs=/home/ubuntu/logs/kafka

inter.broker.protocol.version=3.1
log.message.format.version=3.1
```

### Format Logs Path (If Cluster is New):

```bash
/mnt/kafka_2.13-3.1.0/bin/kafka-storage.sh format \
    --config /mnt/config/kafka_3_1_0/kraft_server.properties \
    --cluster-id U2TYzXg8Q2ODk3o0eiW6YQ \
    --ignore-formatted
```

### Start KRaft Kafka 3.1.0:

```bash
/mnt/kafka_2.13-3.1.0/bin/kafka-server-start.sh /mnt/config/kafka_3_1_0/kraft_server.properties
```

### Create Sample Data:

```bash
/mnt/kafka_2.13-3.1.0/bin/kafka-console-producer.sh --bootstrap-server localhost:9092 --topic cagri
```

```bash
# Output
> 1
> 2
> 3
```

### Read Sample Data to Ensure:

```bash
/mnt/kafka_2.13-3.1.0/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic cagri --from-beginning
```

```bash
# Output
1
2
3
```

### Download and Install Kafka 3.8.0:
The container already have the kafka version check:

```bash
cd /mnt
```

### Copy Existing server.properties to Replace 3.8.0 server.properties:

```bash
# Your log path must match the one specified in the old server.properties file.
log.dirs=/home/ubuntu/logs/kafka

# Don't make any changes when starting your cluster for the first time.
inter.broker.protocol.version=3.1 
log.message.format.version=3.1
```

### Stop KRaft Kafka 3.1.0:

```bash
# Either press Ctrl+C or
/mnt/kafka_2.13-3.1.0/bin/kafka-server-stop.sh
```

### Start KRaft Kafka 3.8.0:

```bash
/mnt/kafka_2.13-3.8.0/bin/kafka-server-start.sh /mnt/config/kafka_3_8_0/kraft_server.properties
```

### Check Topics:

```bash
./kafka-topics.sh --bootstrap-server localhost:9092 --list
```

```bash
# Output
__consumer_offsets
cagri
```

### Verify Data:
```bash
./kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic cagri --from-beginning
```

```bash
# Output
1
2
3
```

### Wait for synchronization to complete, then update the server.properties file.

```bash
# Your log path must match the one specified in the old server.properties file.
log.dirs=/home/ubuntu/logs/kafka

inter.broker.protocol.version=3.8
log.message.format.version=3.8
```

### Stop Kafka 3.8.0:
```bash
# Either press Ctrl+C or
/mnt/kafka_2.13-3.8.0/bin/kafka-server-stop.sh
```

### Start Kafka 3.8.0 Again:
```bash
/mnt/kafka_2.13-3.8.0/bin/kafka-server-start.sh /mnt/config/kafka3_8_0/kraft_server.properties
```

### Check Topics:

```bash
./kafka-topics.sh --bootstrap-server localhost:9092 --list
```

```bash
# Output
__consumer_offsets
cagri
```

### Verify Data:

```bash
/mnt/kafka_2.13-3.8.0/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic cagri --from-beginning
```

```bash
# Output
1
2
3
```

## References:
- https://kafka.apache.org/documentation/#upgrade
- https://learn.conduktor.io/kafka/kafka-broker-and-client-upgrades/