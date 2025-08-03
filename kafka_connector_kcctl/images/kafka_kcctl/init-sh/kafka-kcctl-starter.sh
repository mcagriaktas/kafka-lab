#!/bin/bash

echo "Kafka-kcctl..."

sleep 10 

echo "Exporting kafka-kcctl configs"
/opt/kafka_kcctl/bin/kcctl config set-context cagri-cluster \
  --cluster=http://kafka-connector:8083 \
  --bootstrap-servers=kafka1:9092,kafka2:9092,kafka3:9092 \
  --offset-topic=_connect-offsets

echo "Kafka-Kcctl Version"
/opt/kafka_kcctl/bin/kcctl -V

echo "Current Context"
/opt/kafka_kcctl/bin/kcctl config current-context
echo ""

echo "Kafka-Kcctl..."
tail -f /dev/null