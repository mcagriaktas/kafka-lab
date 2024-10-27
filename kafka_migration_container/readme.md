# Kafka Migration Guide: ZooKeeper to KRaft

This guide demonstrates how to migrate from a ZooKeeper-based Kafka cluster to KRaft mode using MirrorMaker 2. The process includes setting up both Kafka versions and migrating data between them. Note that while ACLs (Access Control Lists) can be migrated using MirrorMaker 2, this demo focuses on the basic migration without SASL/SSL security configurations.

## Prerequisites

- Docker and Docker Compose installed
- Basic understanding of Apache Kafka
- Sufficient disk space for logs and data

## Quick Start

1. Start the Red-Hat container:
```bash
docker-compose up -d --build
```

2. Access the container:
```bash
docker exec -it kafka bash
```

3. Create logs directory:
```bash
mkdir /mnt/all_logs
```

## Configuration Steps

### 1. KRaft Kafka Setup (3.8.0)

1. Configure `server.properties` for KRaft mode (`/config/kraft/server.properties`):
```properties
listeners=PLAINTEXT://:9094,CONTROLLER://:9093
advertised.listeners=PLAINTEXT://localhost:9094
log.dirs=/mnt/all_logs/kafka
```

2. Generate cluster ID:
```bash
./mnt/kafka_2.13-3.8.0/bin/kafka-storage.sh format \
    --config /mnt/kafka_2.13-3.8.0/config/kraft/server.properties \
    --cluster-id U2TYzXg8Q2ODk3o0eiW6YQ \
    --ignore-formatted
```

### 2. ZooKeeper Configuration (3.7.2)

Create and configure `zoo.cfg` (`/mnt/apache-zookeeper-3.7.2-bin/conf/zoo.cfg`):
```properties
tickTime=2000
dataDir=/mnt/all_logs/zookeeper_data
clientPort=2181
initLimit=10
syncLimit=5
```

### 3. MirrorMaker 2 Configuration

Create `mm2.properties` (`/mnt/mm2.properties`):
```properties
# Cluster aliases
clusters = source, destination

# Connection information
source.bootstrap.servers = localhost:9092
destination.bootstrap.servers = localhost:9094

# Replication flow
source->destination.enabled = true
source->destination.topics = topic.*
source->destination.groups = .*

# Topic blacklist
topics.blacklist="*.internal,__.*"

# Replication factors
replication.factor=1
checkpoints.topic.replication.factor=1
heartbeats.topic.replication.factor=1
offset-syncs.topic.replication.factor=1
offset.storage.replication.factor=1
status.storage.replication.factor=1
config.storage.replication.factor=1

# Replication policy
replication.policy.class = org.apache.kafka.connect.mirror.IdentityReplicationPolicy
```

## Migration Process

### 1. Start ZooKeeper-based Kafka

1. Start ZooKeeper:
```bash
./mnt/apache-zookeeper-3.7.2-bin/bin/zkServer.sh start
```

2. Start Kafka (ZooKeeper version):
```bash
./mnt/kafka_2.13-3.1.0/bin/kafka-server-start.sh /mnt/kafka_2.13-3.1.0/config/server.properties
```

### 2. Create Test Data

1. Create a test topic:
```bash
./mnt/kafka_2.13-3.1.0/bin/kafka-topics.sh --bootstrap-server localhost:9092 --create --topic topic1
```

2. Produce test messages:
```bash
./mnt/kafka_2.13-3.1.0/bin/kafka-console-producer.sh --bootstrap-server localhost:9092 --topic topic1
```

3. Verify messages:
```bash
./mnt/kafka_2.13-3.1.0/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic topic1 --from-beginning
```

### 3. Start KRaft Kafka

Start the KRaft version:
```bash
./mnt/kafka_2.13-3.8.0/bin/kafka-server-start.sh /mnt/kafka_2.13-3.8.0/config/kraft/server.properties
```

### 4. Run MirrorMaker 2

Start the migration:
```bash
./mnt/kafka_2.13-3.8.0/bin/connect-mirror-maker.sh /mnt/mm2.properties
```

### 5. Cleanup

1. Stop MirrorMaker 2:
```bash
# Press Ctrl+C in the MirrorMaker 2 terminal
```

2. Stop the old Kafka cluster:
```bash
# Press Ctrl+C in the old Kafka terminal
```

3. Stop ZooKeeper:
```bash
lsof -i :2181
kill -p <PID_ID>
```

## Post-Migration Steps

1. Verify data consistency between old and new clusters
2. Update client applications to use the new Kafka cluster endpoints
3. Remove ZooKeeper-related configurations
4. Archive or delete old cluster data as needed

## References

- [Confluent Documentation](https://docs.confluent.io/platform/current/installation/migrate-zk-kraft.html)
- [Microsoft Event Hubs Tutorial](https://learn.microsoft.com/tr-tr/azure/event-hubs/event-hubs-kafka-mirror-maker-tutorial)
- [Apache Kafka MirrorMaker Guide](https://medium.com/real-time-streaming/apache-kafka-mirror-maker-1400efeca94d)
- [HDInsight Kafka MirrorMaker 2.0 Guide](https://github.com/MicrosoftDocs/azure-docs/blob/main/articles/hdinsight/kafka/kafka-mirrormaker-2-0-guide.md)