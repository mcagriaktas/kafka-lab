# Kafka Commands Guide
In this Kafka setup, you can use `3-broker Kafka cluster`. The `Kafka UI (Provectus)` is accessible at `localhost:8080`. The `Prometheus UI` at `localhost:9090` allows monitoring of all Kafka broker metrics through `JMX exporters (localhost:7071, localhost:7072, localhost:7073)`, `Grafana` at `localhost:3000` provides metric visualization and `KSQL CLI` at `ksql http://localhost:8088`. All configuration files `(*.properties and *.yml)` are located in the config folder.

1. Basic Topic Operations
2. Producer Operations
3. Consumer Operations
4. Detailed Example
5. Demo: Multi-Partition Consumer Example
6. Example Output
7. KSQL - Command

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
>> Terminal 1 (Partition 0):

```bash
docker exec -it kafka1 bash
./kafka-console-consumer.sh --bootstrap-server localhost:9192 --topic dahbest --from-beginning --partition 0 --property print.key=true
```

>> Terminal 2 (Partition 1):
```bash
docker exec -it kafka2 bash
./kafka-console-consumer.sh --bootstrap-server localhost:9192 --topic dahbest --from-beginning --partition 1 --property print.key=true
```

>> Terminal 3 (Partition 2):
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

> Partition 0 (Terminal 1):
```bash
1        hellow
```

> Partition 1 (Terminal 2):
```bash
4        why didnt you send the message to partition 1
```

> Partition 2 (Terminal 3):
```bash
2        I'm Cagri
3        I'm sure, I am, I
```

## Grafana Monitoring

### Create Basic Topic:

`localhost:8080` ==> `Create Topic` ==> `Set "Number of Partitions" = 3` and `Set "Replication Factor" = 3`

![image](https://github.com/user-attachments/assets/4d6dad1c-8fec-46e8-a5b7-8f0636464bbc)

### Add Prometheus as a data source in Grafana:

1. Login to Grafana (localhost:3000)
2. Click on the hamburger menu icon (☰) in the left sidebar
3. Go to "Connections" -> "Data sources"
4. Click "Add data source"
5. Search and select "Prometheus"
6. Set the URL to http://prometheus:9090
7. Click "Save & test" at the bottom

### Create Dashboard:

![image](https://github.com/user-attachments/assets/7bd8c4c5-8561-4925-9342-34170d8471d5)


## KSQL - Command
### Create Schema
```bash
./kafka-topics.sh --bootstrap-server localhost:9192,kafka2:9192,kafka3:9192 --create --topic cagri-test --replication-factor 3 --partitions 3
```

### Start the Scala Script for producer:
```bash
java jar kafka-docker-setup/PCS-Scripts-Scala-Python/ksql-producer/target/scala-2.12/main-assembly-0.1.0-SNAPSHOT.jar
```

### Access the KSQL - CLI
```bash
docker exec -it ksqldb bash

ksql http://localhost:8088
```

### Create Table for Streaming
```bash
CREATE STREAM cagri_test_stream (
    name VARCHAR,
    age INTEGER
) WITH (
    KAFKA_TOPIC='cagri-test',
    VALUE_FORMAT='JSON'
);
```

### Start Streaming consumer in ksqldb
```bash
SELECT * FROM cagri_test_stream EMIT CHANGES;
```

or

```bash
SELECT name, AVG(age) as avg_age 
FROM cagri_test_stream 
GROUP BY name 
EMIT CHANGES;
```

or 

```bash
SELECT * FROM cagri_test_stream 
WHERE age > 50 
EMIT CHANGES;
```

or 

```bash
SELECT name, COUNT(*) as count 
FROM cagri_test_stream 
GROUP BY name 
EMIT CHANGES;
```