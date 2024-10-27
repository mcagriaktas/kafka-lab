# Kafka Commands Guide
In this Kafka setup, a `single-broker Kafka cluster` with `ZooKeeper` is used. Configuration files can be found in `/config/kafka/server.properties` and `/config/zoo.cfg`. The `Kafka UI (Provectus)` is accessible at `localhost:8080`. All `*.properties` and `*.yml` files are located in the config folder.

## Basic Topic Operations

### Create Topic
```bash
./kafka-topics.sh --zookeeper zookeeper:2181 --create --topic cagri --replication-factor 1 --partitions 3
```

### List Topics
```bash
./kafka-topics.sh --zookeeper zookeeper:2181 --list
```

### Describe Topic
```bash
./kafka-topics.sh --zookeeper zookeeper:2181 --describe --topic cagri
```

### Delete Topic
```bash
./kafka-topics.sh --zookeeper zookeeper:2181 --delete --topic cagri
```

### Modify Topic (Increase Partitions)
```bash
./kafka-topics.sh --zookeeper zookeeper:2181 --alter --topic cagri --partitions 5
```

## Producer Operations

### Start Basic Producer
```bash
./kafka-console-producer.sh --broker-list localhost:9092 --topic cagri
```

### Start Producer with Key
```bash
./kafka-console-producer.sh --broker-list localhost:9092 --topic cagri --property "parse.key=true" --property "key.separator=,"
```

## Consumer Operations

### Start Basic Consumer
```bash
./kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic cagri --from-beginning
```

## Detailed Example

### Basic Topic Creation Explained
```bash
/kafka/bin/kafka-topics.sh \                # Script to manage Kafka topics
--zookeeper zookeeper:2181 \               # Zookeeper server address
--create --topic cagri \                    # Create new topic named 'cagri'
--replication-factor 1 \                    # Number of replicas (single broker)
--partitions 3                              # Number of partitions
```

**Note:** With a single broker, the replication-factor must be 1.

## Demo: Multi-Partition Consumer Example

### 1. Create Topic
```bash
./kafka-topics.sh --zookeeper zookeeper:2181 --create --topic dahbest --replication-factor 1 --partitions 3
```

### 2. Start Consumers (Open 3 Terminals)

#### Terminal 1 (Partition 0):
```bash
docker exec -it kafka bash
./kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic dahbest --from-beginning --partition 0 --property print.key=true
```

#### Terminal 2 (Partition 1):
```bash
docker exec -it kafka bash
./kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic dahbest --from-beginning --partition 1 --property print.key=true
```

#### Terminal 3 (Partition 2):
```bash
docker exec -it kafka bash
./kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic dahbest --from-beginning --partition 2 --property print.key=true
```

### 3. Start Producer
```bash
docker exec -it kafka bash
./kafka-console-producer.sh --broker-list localhost:9092 --topic dahbest --property "parse.key=true" --property "key.separator=,"
```

## Example Output

### Producer Input:
```
1,hellow
2,I'm Cagri
3,I'm sure, I am, I
4,why didnt you send the message to partition 1
```

### Consumer Output:

#### Partition 0 (Terminal 1):
```
1        hellow
```

#### Partition 1 (Terminal 2):
```
4        why didnt you send the message to partition 1
```

#### Partition 2 (Terminal 3):
```
2        I'm Cagri
3        I'm sure, I am, I
```