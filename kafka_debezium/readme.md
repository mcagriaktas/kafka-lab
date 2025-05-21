# Debezium

In this deployment, you can easily find a working Debezium setup and see how to use it with PostgreSQL. Other CDC (Change Data Capture) connectors are also easy to use—just download the appropriate .jar file and configure the *-source.json file.

### 🔧 Project Component Versions & Configuration

| Component             | Description                    | Version         | Port/Details                              |
| --------------------- | ------------------------------ | --------------- | ----------------------------------------- |
| Kafka                 | Distributed event streaming platform (3-node cluster)          | 4.0.0           | Default: 9092                             |
| Scala                 | Required by Kafka              | 2.13            |                                           |
| Debezium              | CDC platform for Kafka Connect | 3.1.1.Final     | Uses Kafka Connect                        |
| Kafka UI (Provectus)  | Web interface for Kafka management          | v0.7.2          | Default: 8080                             |
| PostgreSQL            | Source DB for CDC              | 16              | User: cagri, Port: 3541, DB: postgres |

## 🔑 Key Points:
By following all the steps, you'll understand what Debezium is and why people use it. When you need to capture real-time changes (like INSERT, UPDATE, or DELETE) from a database, Debezium works perfectly with Kafka to stream that data.

But keep in mind:
Debezium is not a Kafka connector itself—it's a Java application that uses Kafka Connect under the hood to stream database changes.

### 1. What's mean op:'c', op:'r', op:'u', op:'d':
```bash
'c' → Create (a new row was inserted)

'r' → Read (a snapshot read; happens during the initial snapshot phase)

'u' → Update (an existing row was updated)

'd' → Delete (a row was deleted)
```

<img width="1920" alt="json_output" src="https://github.com/user-attachments/assets/65eb3abe-23b7-436e-aca9-739ebdba3d15" />

### 2. For Docker Deployment:
Add this to your container's command or entrypoint:
```bash
command: ["postgres", "-c", "wal_level=logical", "-c", "max_wal_senders=10", "-c", "max_replication_slots=10"]   
```

### 3. For Linux Deployment:
Update the `postgresql.conf` file (usually located at `/etc/postgresql/{version}/main/postgresql.conf` or `/var/lib/pgsql/data/postgresql.conf`):
```bash
wal_level = logical
max_wal_senders = 10
max_replication_slots = 10
```

Then, allow replication connections by adding a line to `pg_hba.conf`:
```bash
# TYPE  DATABASE        USER            ADDRESS                 METHOD
host    replication     all             0.0.0.0/0               md5
```

## How to run the deployment:

### When the Containers Are Built and Running:

<img width="1920" alt="main-topics" src="https://github.com/user-attachments/assets/1a965c51-d6e5-4e7d-bb6a-631aa0d7d818" />

### 1. Setup the Database for Debezium
```bash
# Connect to PostgreSQL
docker exec -it postgres psql -U cagri -d postgres

# Create a test table
CREATE TABLE high_customers (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100),
  email VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

# Create a function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

# Create a trigger to call the function
CREATE TRIGGER update_customers_timestamp
BEFORE UPDATE ON high_customers
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

# Enable full replica identity to capture before values
ALTER TABLE high_customers REPLICA IDENTITY FULL;

# Verify replica identity setting
SELECT relname, relreplident FROM pg_class WHERE relname = 'high_customers';
# Should return 'f' for FULL

# Insert initial data
INSERT INTO high_customers (name, email) 
VALUES 
  ('Cagri Dahbest', 'asdasdasd@example.com'),
  ('Hazel Dahbest', 'asdasdassssd@example.com');
```

### 3. Register the Debezium PostgreSQL connector
```bash
curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" \
  http://localhost:8083/connectors/ -d @data/high_postgres-source.json
```

<img width="1772" alt="kafka-ui" src="https://github.com/user-attachments/assets/c92808fe-9148-4701-9f1b-06794c2a7ec8" />

### ⚠️ 3.1 Delete existing connector if needed
```bash
⚠️ curl -X DELETE http://localhost:8083/connectors/postgres-source
```

### 4. Check connector status
```bash
curl -s http://localhost:8083/connectors/postgres-source/status | jq
```

### 5. Open two terminal panels and start both consumers to observe the changes in real time:
```bash
# Python consumer to easily observe changes in the database table and Kafka topics!
python data/debeizum_consumer.py

# Listen to the topic where PostgreSQL changes will be published
docker exec -it kafka1 /opt/kafka/bin/kafka-console-consumer.sh \
  --bootstrap-server kafka1:9092,kafka2:9092,kafka3:9092 \
  --topic dbserver1.public.high_customers \
  --from-beginning
```

### 6. Update, Delete and Insert (op:'c', op:'r', op:'u', op:'d')
```bash
# Connect to PostgreSQL
docker exec -it postgres psql -U cagri -d postgres

# Make updates to see before/after values
UPDATE high_customers SET email = 'mucagriaktas@gmail.com' WHERE id = 1;
UPDATE high_customers SET name = 'Cagri A. Dahbest' WHERE id = 1;
UPDATE high_customers SET email = 'hazeldahbest@gmail.com' WHERE id = 2;

# Delete a record to test delete events
DELETE FROM high_customers WHERE id = 2;

# Insert a new record to test insert events
INSERT INTO high_customers (name, email) VALUES ('New User', 'new@example.com');
```

## Docs:

- [Debezium PostgreSQL](https://debezium.io/documentation/reference/1.9/connectors/postgresql.html)
- [Debezium Offical Docker Demo](https://debezium.io/documentation/reference/stable/tutorial.html)
