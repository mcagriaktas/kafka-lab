# Kafka Commands Guide
In this Kafka setup, you can use a `3-broker` Kafka cluster. The `Kafka UI (Provectus)` is accessible at `localhost:8080`. All `*.properties` and `*.yml` files are located in the config folder.

## Basic Topic Operations

### Create Topic
```bash
./kafka-topics.sh --bootstrap-server localhost:9192 --create --topic cagri --replication-factor 3 --partitions 3
```

### List Topics
```bash
./kafka-topics.sh --bootstrap-server localhost:9192 --list
```

### Describe Topic
```bash
./kafka-topics.sh --bootstrap-server localhost:9192 --describe --topic cagri
```

### Delete Topic
```bash
./kafka-topics.sh --bootstrap-server localhost:9192 --delete --topic cagri
```

### Modify Topic (Increase Partitions)
```bash
./kafka-topics.sh --bootstrap-server localhost:9192 --alter --topic cagri --partitions 5
```

## Producer Operations

### Start Basic Producer
```bash
./kafka-console-producer.sh --bootstrap-server localhost:9192 --topic cagri
```

### Start Producer with Key
```bash
./kafka-console-producer.sh --bootstrap-server localhost:9192 --topic cagri --property "parse.key=true" --property "key.separator=,"
```

## Consumer Operations

### Start Basic Consumer
```bash
./kafka-console-consumer.sh --bootstrap-server localhost:9192 --topic cagri --from-beginning
```

## Detailed Example

### Basic Topic Creation Explained
```bash
/kafka/bin/kafka-topics.sh \                # Script to manage Kafka topics
--bootstrap-server kafka:9192 \             # Kafka server address
--create --topic cagri \                    # Create new topic named 'cagri'
--replication-factor 3 \                    # Number of replicas
--partitions 3                              # Number of partitions
```

**Note:** Maximum replication-factor is 3 when deploying 3 brokers.

## Demo: Multi-Partition Consumer Example

### 1. Create Topic
```bash
./kafka-topics.sh --bootstrap-server localhost:9192 --create --topic dahbest --replication-factor 3 --partitions 3
```

### 2. Start Consumers (Open 3 Terminals)

#### Terminal 1 (Partition 0):
```bash
docker exec -it kafka1 bash
./kafka-console-consumer.sh --bootstrap-server localhost:9192 --topic dahbest --from-beginning --partition 0 --property print.key=true
```

#### Terminal 2 (Partition 1):
```bash
docker exec -it kafka2 bash
./kafka-console-consumer.sh --bootstrap-server localhost:9192 --topic dahbest --from-beginning --partition 1 --property print.key=true
```

#### Terminal 3 (Partition 2):
```bash
docker exec -it kafka3 bash
./kafka-console-consumer.sh --bootstrap-server localhost:9192 --topic dahbest --from-beginning --partition 2 --property print.key=true
```

### 3. Start Producer
```bash
docker exec -it kafka1 bash
./kafka-console-producer.sh --bootstrap-server localhost:9192 --topic dahbest --property "parse.key=true" --property "key.separator=,"
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