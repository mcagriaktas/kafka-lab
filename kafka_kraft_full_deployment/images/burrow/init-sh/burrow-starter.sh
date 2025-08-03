#!/bin/bash

echo "Waiting for Kafka brokers..."

for i in {1..30}; do
    nc -z kafka1 9092 && nc -z kafka2 9092 && nc -z kafka3 9092 && break
    echo "Kafka not ready, retrying in 5s..."
    sleep 5
done

echo "All brokers are up. Waiting for Kafka cluster to stabilize..."
sleep 15

echo "Kafka ready. Starting Burrow..."

export GOMAXPROCS=4

touch /opt/logs/burrow.log
chmod 777 /opt/logs/burrow.log

echo "Fetching Kafka __consumer_offsets topic and restarting Burrow..."
exec /opt/burrow --config-dir /opt/ &
tail -f /opt/logs/burrow.log