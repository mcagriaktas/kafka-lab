# Kafka KSQL

This project deploys a robust, production-like streaming stack centered around KSQLDB — the powerful SQL engine for Apache Kafka. With a 3-broker Kafka cluster, Provectus Kafka UI, and a Python-based data producer, you get everything needed to build, test, and experiment with real-time stream processing directly on Kafka topics.

KSQLDB enables you to write streaming queries and analytics with simple SQL syntax — no need for Java or Scala. You can join topics, aggregate events in real time, filter and transform messages as they arrive, or build materialized views for dashboards and APIs. This makes event-driven applications and real-time reporting accessible to any developer familiar with SQL, right on top of Kafka.

In this deployment, you can:
  - Produce live data to Kafka from Python or the CLI.
  - Use KSQLDB’s CLI to define streams and tables on top of raw topics.
  - Write SQL queries to filter, aggregate, and join event streams — all running continuously and updating in real time as new data arrives.
  - Instantly view your Kafka topics and messages using the Provectus Kafka UI.
  - Experiment with complex streaming logic without writing a single line of Java code.
  - Whether you want to build streaming ETL, real-time leaderboards, anomaly detection, or dashboards — KSQLDB with this stack is a fast, developer-friendly entry point to the world of real-time analytics on Kafka.

---

## 📂 Folder Architecture

```bash
.
├── config/
│   ├── server.properties
│   ├── ksqldb.properties
│   └── ...
├── data_generator/
│   └── producer.py
└── docker-compose.yml
```

---

## 🌐 Key Endpoints

| Service       | URL                                       |
|---------------|-------------------------------------------|
| **Kafka UI**| [http://localhost:8080](http://localhost:8080)         |
| **KSQL CLI**| [http://localhost:8000/v3/kafka](http://localhost:8000/v3/kafka)|
| **Kafka**     | Internal: `kafka{1,2,3}:9092`, External: `localhost:19092,29092,39092` |

---

## 🚀 Getting Started

1. **Start all services:**
    ```bash
    docker-compose up -d --build
    ```
2. **Create a Topic:**
    ```bash
    docker exec -it kafka1 /opt/kafka/bin/kafka-topics.sh   --bootstrap-server kafka1:9092,kafka2:9092,kafka3:9092   --create --topic ksql-topic --replication-factor 3 --partitions 3
    ```

3. **Produce Sample Data:**
    ```bash
    python data_generator/producer.py
    ```

4. **Access KSQL CLI**
    ```bash
    docker exec -it ksqldb bash
    /opt/ksqldb/bin/ksql http://ksqldb:8088
    ```

---

## 💡 KSQLDB Example Commands

1. **Create a Stream:**
    ```sql
    CREATE STREAM cagri_test_stream (
        name VARCHAR,
        age INTEGER
    ) WITH (
        KAFKA_TOPIC='ksql-topic',
        VALUE_FORMAT='JSON'
    );
    ```

2. **Query Examples:**

    **Read All Data (Streaming):**
    ```sql
    SELECT * FROM cagri_test_stream EMIT CHANGES;
    ```

    **Average Age by Name:**
    ```sql
    SELECT name, AVG(age) as avg_age 
    FROM cagri_test_stream 
    GROUP BY name 
    EMIT CHANGES;
    ```

    **Filter by Age:**
    ```sql
    SELECT * FROM cagri_test_stream 
    WHERE age > 50 
    EMIT CHANGES;
    ```

    **Count by Name:**
    ```sql
    SELECT name, COUNT(*) as count 
    FROM cagri_test_stream 
    GROUP BY name 
    EMIT CHANGES;
    ```

---