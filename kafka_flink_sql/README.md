# Flink Demo

## Prerequisites
- Linux Env.
- Docker
- Docker-compose

### Configs:
Check the `config/*_manager/flink-conf.yaml` file and adjust the process size based on your RAM capacity and streaming batch size.
```yaml
jobmanager.memory.process.size: 10gb  
taskmanager.memory.process.size: 20gb
taskmanager.numberOfTaskSlots: 4

execution.checkpointing.interval: 1000       # 1 second for refrection (default 180000)
execution.checkpointing.mode: AT_LEAST_ONCE
```

### Important!

⚠️ Check the Flink SQL Configuration: `https://nightlies.apache.org/flink/flink-docs-master/docs/dev/table/sqlclient/`

⚠️ If you want to store your SQL table, you need to use a catalog tool such as Hive. If you don't want to use a catalog, you can create your own init-catalog.sql and start with:

## Setup Containers:
```bash
docker network create --subnet=172.80.0.0/16 dahbest

docker-compose up -d --build
```

### Start Producer for demo:
```bash
python jobs/producer.py
```

### Start Flink SQL Client:
```bash
docker exec -it jobmanager bin/sql-client.sh gateway --endpoint localhost:8082 --init /opt/flink/jobs/init-catalog.sql
```

### Start Streaming with Your Kafka Topic:
If you are trying to produce your data, check jobs/table-kafka.sql for the data structure.

```sql
select * from kafka_source;
```

### Check flink-conf.yaml metrics:
```
https://nightlies.apache.org/flink/flink-docs-master/docs/deployment/config/
```




