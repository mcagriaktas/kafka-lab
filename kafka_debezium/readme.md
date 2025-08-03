# Debezium + PostgreSQL CDC Example

This repository offers a ready-to-run environment for demonstrating Change Data Capture (CDC) from PostgreSQL to Kafka using Debezium. The setup is designed to make it easy to explore real-time data streaming and CDC patterns, with full support for other Debezium CDC connectors—simply add the necessary JAR file and source configuration for your use case.

Out of the box, the stack provides everything you need to capture database changes from PostgreSQL and stream them to Kafka topics. It also includes a Kafka UI, making it simple to monitor topics, inspect events, and manage your CDC pipeline visually. Sample consumer applications are included for quick and easy testing, allowing you to see captured changes in action without extra configuration.

This project is ideal for developers and data engineers who want to learn about CDC, experiment with Debezium’s connectors, or build real-time data pipelines between relational databases and Kafka. With minimal setup, you can observe how changes in your PostgreSQL database are instantly reflected in Kafka, and expand the environment to support additional CDC sources as needed.

---

## 📁 Project Structure

```
.
├── configs/                        # Service configurations
│   ├── kafka/                      # Kafka broker configs
│   ├── debezium/                   # Debezium connector configs (source JSONs)
│   └── postgres/                   # PostgreSQL init/config scripts
├── data_generator/                 # Python consumer, example scripts
│   ├── debeizum_consumer.py        # Python consumer for CDC topics
│   └── high_postgres-source.json   # Example Debezium connector config
├── docker-compose.yml              # Orchestration for the stack
├── images/                         # Custom images if any
├── logs/                           # Logs from running containers
├── screenshots/                    # Docs and UI screenshots
└── README.md
```

---

## 🌐 Key Endpoints

| Service           | URL                                  | Notes / Credentials                      |
|-------------------|--------------------------------------|------------------------------------------|
| **Kafka UI**      | [http://localhost:8080](http://localhost:8080) | Provectus UI, browse topics, view data   |
| **Kafka Connect** | [http://localhost:8083](http://localhost:8083) | REST API for connector registration      |
| **PostgreSQL**    | Host: `localhost`, Port: `3541`      | User: `cagri`, DB: `postgres`, PW: `35413541` |

---

## 📊 What is Debezium?

[**Debezium**](https://debezium.io/) is an open-source CDC platform that captures row-level changes (INSERT/UPDATE/DELETE) from your databases and streams them into Kafka topics in real time.  
- Built as a set of Kafka Connect connectors.
- Makes it easy to build event-driven applications, replicate data, and maintain audit trails.

**Operation types (`op`):**
```
'c' – Create (insert)
'r' – Read (snapshot row, initial snapshot phase)
'u' – Update
'd' – Delete
```

---

## ⚡ Quick Start

### 1. Start the Stack

```bash
docker-compose up -d
```

### 2. Ensure PostgreSQL is CDC-ready

**Docker:**  
Add this to the container `command` or `entrypoint`:
```bash
command: ["postgres", "-c", "wal_level=logical", "-c", "max_wal_senders=10", "-c", "max_replication_slots=10"]
```

**Linux:**  
Edit `postgresql.conf`:
```conf
wal_level = logical
max_wal_senders = 10
max_replication_slots = 10
```
And in `pg_hba.conf`, add:
```
host    replication     all             0.0.0.0/0               md5
```

### 3. Initialize Database

```bash
docker exec -it postgres psql -U cagri -d postgres

-- Create test table
CREATE TABLE high_customers (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100),
  email VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create trigger to auto-update `updated_at`
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_customers_timestamp
BEFORE UPDATE ON high_customers
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

-- Enable full replica identity for CDC
ALTER TABLE high_customers REPLICA IDENTITY FULL;

-- (Verify with)
SELECT relname, relreplident FROM pg_class WHERE relname = 'high_customers';

-- Insert sample data
INSERT INTO high_customers (name, email) VALUES
  ('Cagri Dahbest', 'asdasdasd@example.com'),
  ('Hazel Dahbest', 'asdasdassssd@example.com');
```

### 4. Register the Debezium PostgreSQL Connector

```bash
curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" http://localhost:8083/connectors/ -d @data_generator/high_postgres-source.json
```

**Delete existing connector (if needed):**
```bash
curl -X DELETE http://localhost:8083/connectors/postgres-source
```

**Check connector status:**
```bash
curl -s http://localhost:8083/connectors/postgres-source/status | jq
```

### 5. Observe CDC Events

Open **two terminals**:

- **Python consumer (pretty-print JSON):**
  ```bash
  python data_generator/debeizum_consumer.py
  ```

- **Kafka console consumer (raw view):**
  ```bash
  docker exec -it kafka1 /opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server kafka1:9092,kafka2:9092,kafka3:9092 --topic dbserver1.public.high_customers --from-beginning
  ```

### 6. Make Some Changes!

```bash
docker exec -it postgres psql -U cagri -d postgres

UPDATE high_customers SET email = 'mucagriaktas@gmail.com' WHERE id = 1;
UPDATE high_customers SET name = 'Cagri A. Dahbest' WHERE id = 1;
UPDATE high_customers SET email = 'hazeldahbest@gmail.com' WHERE id = 2;
DELETE FROM high_customers WHERE id = 2;
INSERT INTO high_customers (name, email) VALUES ('New User', 'new@example.com');
```

Check your consumers to see the corresponding `op: 'c' | 'u' | 'd'` messages.

---

## 🛠️ Customization

- **Add new CDC source:**  
  Drop in another connector JAR, create a new `*-source.json` file, register it using the Connect REST API.
- **Change topics, table names, or DB settings:**  
  Edit `high_postgres-source.json` and PostgreSQL schema as needed.
- **Monitor with Kafka UI:**  
  Browse and inspect messages on all topics at [http://localhost:8080](http://localhost:8080).

---

## 📝 Notes & Tips

- Always **enable `REPLICA IDENTITY FULL`** for any table where you want Debezium to capture update/delete "before" images.
- Debezium supports **many other DBs** (MySQL, SQL Server, MongoDB, Oracle, etc.)—just use the relevant connector JAR and config.
- Sample **screenshots** in the `/screenshots` folder.

---

## 📚 References

- [Debezium PostgreSQL Connector](https://debezium.io/documentation/reference/1.9/connectors/postgresql.html)
- [Debezium Official Docker Demo](https://debezium.io/documentation/reference/stable/tutorial.html)
- [Kafka Connect Documentation](https://kafka.apache.org/documentation/#connect)
- [Provectus Kafka UI](https://github.com/provectus/kafka-ui)

---