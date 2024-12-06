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
./zkServer.sh start
```

### Add These Config Lines in server.properties:

```bash
log.dirs=/home/ubuntu/logs/kafka

inter.broker.protocol.version=3.1
log.message.format.version=3.1
```

### Start Kafka 3.1.0:

```bash
./kafka-server-start.sh /mnt/kafka_2.13-3.1.0/config/server.properties
```

### Create Sample Data:

```bash
./kafka-console-producer.sh --bootstrap-server localhost:9092 --topic cagri
```

```bash
# Output
> 1
> 2
> 3
```

### Read Sample Data to Ensure:

```bash
./kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic cagri --from-beginning
```

```bash
# Output
1
2
3
```

### Stop Kafka 3.1.0:

```bash
# Either press Ctrl+C in terminal or
./kafka-server-stop.sh
```

### Download and Install New Kafka 3.8.0:
The container already have the kafka version check:

```bash
cd /mnt
```

### Copy Existing server.properties to Replace 3.8.0 server.properties:
```bash
log.dirs=/home/ubuntu/logs/kafka

zookeeper.connect=localhost:2181
zookeeper.connection.timeout.ms=18000
migration.enabled=true

# Don't change these on first start
inter.broker.protocol.version=3.1
log.message.format.version=3.1
```

### Start Kafka 3.8.0:
```bash
./kafka-server-start.sh /mnt/kafka_2.13-3.8.0/config/server.properties
```

### Check Topics:
```bash
./kafka-topics.sh --bootstrap-server localhost:9092 --list
```

__consumer_offsets
cagri

### Stop Kafka 3.1.0:
```bash
# Either press Ctrl+C or
./kafka-server-stop.sh
```

### Stop Kafka 3.8.0:
```bash
# Either press Ctrl+C or
./kafka-server-stop.sh
```

### Update 3.8.0 server.properties:
```bash
inter.broker.protocol.version=3.8
log.message.format.version=3.8
```

### Start Kafka 3.8.0 Again:
```bash
./kafka-server-start.sh /mnt/kafka_2.13-3.8.0/config/server.properties
```

### Verify Data:
```bash
./kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic cagri --from-beginning
```

### Read Sample Data:

```bash
# Output
1
2
3
```

## Upgrade KRaft Version Kafka 3.1.0 to Kafka 3.8.0

### server.properties for KRaft:
`The file in the config/kraft/server.properties`

```bash
log.dirs=/home/ubuntu/logs/kafka

inter.broker.protocol.version=3.1 
log.message.format.version=3.1 
```

### Format Logs Path (If Cluster is New):
```bash
./kafka-storage.sh format \
    --config /mnt/kafka_2.13-3.1.0/config/kraft/server.properties \
    --cluster-id U2TYzXg8Q2ODk3o0eiW6YQ \
    --ignore-formatted
```

### Start KRaft Kafka 3.1.0:
```bash
./kafka-server-start.sh /mnt/kafka_2.13-3.1.0/config/kraft/server.properties
```

### Create Example Data:
```bash
./kafka-console-producer.sh --bootstrap-server localhost:9092 --topic cagri
```

```bash
# Output
>1
>2
>3
```

```bash
./kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic cagri --from-beginning
```

```bash
# Output
1
2
3
```

### Stop KRaft Kafka 3.1.0:
```bash
# Either press Ctrl+C or
./bin/kafka-server-stop.sh
```

### Download and Install Kafka 3.8.0:
The container already have the kafka version check:

```bash
cd /mnt
```

### Start Kafka 3.8.0:
```bash
# Don't change the protocol on first start
log.dirs=/home/ubuntu/logs/kafka

inter.broker.protocol.version=3.1
log.message.format.version=3.1
```

### Start KRaft Kafka 3.8.0:
```bash
./kafka-server-start.sh /mnt/kafka_2.13-3.8.0/config/kraft/server.properties
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

### Update server.properties:
```bash
inter.broker.protocol.version=3.8 
log.message.format.version=3.8
```

### Start KRaft Kafka 3.8.0:
```bash
./kafka-server-start.sh /mnt/kafka_2.13-3.8.0/config/kraft/server.properties
```

### Verify KRaft Kafka 3.8.0:
```bash
./kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic cagri --from-beginning
```

```bash
# Output
1
2
3
```
