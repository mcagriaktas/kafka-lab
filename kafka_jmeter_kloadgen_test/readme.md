# Kafka Avro/JSON Schema-Registry Performance Testing

This project demonstrates how to perform performance testing on Apache Kafka using JMeter with Avro and JSON serialization formats. The demo includes a complete setup with Docker containers for Kafka and Schema Registry, along with tools to generate and measure message throughput.

## Features

- Docker containers for Kafka and Confluent Schema Registry
- JMeter test setup with KLoadGen (Kafka Load Generator)
- Example schemas for both Avro and JSON formats
- Sample test data representing hotel reviews
- Pre-configured test plan (.jmx file)
- High-partition topic configuration (72 partitions) to test scalability
- Step-by-step instructions for deployment and execution

## Requirements

- Java 11+ (not including 11)
- JMeter 5.4+
- Maven (Any Version)
- Linux/WSL

## Architecture

![image](https://github.com/user-attachments/assets/79fc8983-1366-4868-926f-4817a75051db)

## Setup Instructions

### 1. Clone the repository

```bash
git clone https://github.com/mcagriaktas/kafka-container-setup.git
cd kafka-container-setup/kakfa_jmeter_kloadgen_test
```

### 2. Create Docker Network

```bash
docker network create --subnet=172.80.0.0/16 dahbest
```

### 3. Build Docker Containers

```bash
docker-compose up -d --build
```

### 4. Download JMeter

```bash
wget https://dlcdn.apache.org//jmeter/binaries/apache-jmeter-5.6.3.tgz
tar -xzf apache-jmeter-5.6.3.tgz
```

### 5. Build KLoadGen

```bash
git clone https://github.com/sngular/kloadgen.git
cd kloadgen
mvn clean install -P plugin
```

### 6. Register Schemas with Schema Registry

#### Register AVRO Schema:

```bash
curl -X POST -H "Content-Type: application/vnd.schemaregistry.v1+json" \
  --data '{
    "schema": "{\"type\":\"record\",\"name\":\"HotelReview\",\"namespace\":\"com.hotel.reviews\",\"fields\":[{\"name\":\"review_id\",\"type\":\"string\"},{\"name\":\"hotel_id\",\"type\":\"string\"},{\"name\":\"user_id\",\"type\":\"string\"},{\"name\":\"rating\",\"type\":\"float\"},{\"name\":\"review_date\",\"type\":{\"type\":\"string\",\"logicalType\":\"date\"}},{\"name\":\"stay_duration\",\"type\":\"int\"},{\"name\":\"traveler_type\",\"type\":\"string\"},{\"name\":\"room_type\",\"type\":\"string\"},{\"name\":\"title\",\"type\":\"string\"},{\"name\":\"review_text\",\"type\":\"string\"},{\"name\":\"helpful_votes\",\"type\":\"int\"},{\"name\":\"location_score\",\"type\":\"float\"},{\"name\":\"service_score\",\"type\":\"float\"},{\"name\":\"cleanliness_score\",\"type\":\"float\"},{\"name\":\"value_score\",\"type\":\"float\"},{\"name\":\"is_verified\",\"type\":\"boolean\"},{\"name\":\"language\",\"type\":\"string\"},{\"name\":\"country_origin\",\"type\":\"string\"},{\"name\":\"has_response\",\"type\":\"boolean\"},{\"name\":\"booking_channel\",\"type\":\"string\"}]}"
  }' \
  http://localhost:8081/subjects/hoteldata_avro-value/versions
```

#### Register JSON Schema:

```bash
curl -X POST -H "Content-Type: application/vnd.schemaregistry.v1+json" \
--data '{
"schemaType": "JSON",
"schema": "{\"$schema\":\"http://json-schema.org/draft-07/schema#\",\"title\":\"HotelReview\",\"type\":\"object\",\"properties\":{\"review_id\":{\"type\":\"string\"},\"hotel_id\":{\"type\":\"string\"},\"user_id\":{\"type\":\"string\"},\"rating\":{\"type\":\"number\"},\"review_date\":{\"type\":\"string\",\"format\":\"date\"},\"stay_duration\":{\"type\":\"integer\"},\"traveler_type\":{\"type\":\"string\"},\"room_type\":{\"type\":\"string\"},\"title\":{\"type\":\"string\"},\"review_text\":{\"type\":\"string\"},\"helpful_votes\":{\"type\":\"integer\"},\"location_score\":{\"type\":\"number\"},\"service_score\":{\"type\":\"number\"},\"cleanliness_score\":{\"type\":\"number\"},\"value_score\":{\"type\":\"number\"},\"is_verified\":{\"type\":\"boolean\"},\"language\":{\"type\":\"string\"},\"country_origin\":{\"type\":\"string\"},\"has_response\":{\"type\":\"boolean\"},\"booking_channel\":{\"type\":\"string\"}},\"required\":[\"review_id\",\"hotel_id\",\"user_id\",\"rating\",\"review_date\"]}"
}' \
http://localhost:8081/subjects/hoteldata_json-value/versions
```

### 7. Create Sample Data
You can find the `sample data` in the `test_file folder`. `JMeter will use KLoadGen to loop over the sample data`, so you can use a single line of data without any issues. No need to worry!

### 8. Create Kafka Topics

```bash
# AVRO Topic
./kafka-topics.sh --create --topic hotel-avro --partitions 72 --replication-factor 1 --bootstrap-server localhost:19092

# JSON Topic
./kafka-topics.sh --create --topic hotel-json --partitions 72 --replication-factor 1 --bootstrap-server localhost:19092
```

### Note: You can use my other Kafka setup to deploy 3 Kafka brokers for real testing. 

## Running the Test

1. Start JMeter:
   ```bash
   ./apache-jmeter-5.6.3/bin/jmeter
   ```

2. Load the test plan:
   ```
   File → Open → test_file → avro_json.jmx
   ```

3. Start the test and observe results in the Summary Report.

## Troubleshooting

If you encounter SLF4J binding issues, install the required JAR:
```bash
wget https://repo1.maven.org/maven2/org/slf4j/slf4j-simple/1.7.36/slf4j-simple-1.7.36.jar -P ./apache-jmeter-5.6.3/lib
```
