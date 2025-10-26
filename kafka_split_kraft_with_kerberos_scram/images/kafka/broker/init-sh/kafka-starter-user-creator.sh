#!/bin/bash

sleep 15

echo "Kafka Admin user creating."
/opt/kafka/bin/kafka-configs.sh \
    --bootstrap-server broker1.dahbest.kfn:9092,broker2.dahbest.kfn:9092,broker3.dahbest.kfn:9092 \
    --command-config /opt/kafka/config/gssapi-admin-client.properties \
    --alter \
    --add-config "SCRAM-SHA-256=[password=cagri3541]" \
    --entity-type users \
    --entity-name "kafka"

echo ""

echo "Kafka Admin user's ACLS adding."
/opt/kafka/bin/kafka-acls.sh \
    --bootstrap-server broker1.dahbest.kfn:9092,broker2.dahbest.kfn:9092,broker3.dahbest.kfn:9092 \
    --command-config /opt/kafka/config/gssapi-admin-client.properties \
    --add \
    --allow-principal "User:kafka" \
    --operation All \
    --topic '*' \
    --group '*' \
    --cluster

echo ""

echo "kafka-ui user creating."
/opt/kafka/bin/kafka-configs.sh \
    --bootstrap-server broker1.dahbest.kfn:9092,broker2.dahbest.kfn:9092,broker3.dahbest.kfn:9092 \
    --command-config /opt/kafka/config/gssapi-admin-client.properties \
    --alter \
    --add-config "SCRAM-SHA-256=[password=cagri3541]" \
    --entity-type users \
    --entity-name "kafkaui"

echo ""

echo "kafka-ui user's ACLS adding."
/opt/kafka/bin/kafka-acls.sh \
    --bootstrap-server broker1.dahbest.kfn:9092,broker2.dahbest.kfn:9092,broker3.dahbest.kfn:9092 \
    --command-config /opt/kafka/config/gssapi-admin-client.properties \
    --add \
    --allow-principal "User:kafkaui" \
    --operation All \
    --topic '*' \
    --group '*' \
    --cluster

echo ""

echo "cagri-test topic is creating..."
/opt/kafka/bin/kafka-topics.sh \
  --bootstrap-server broker1.dahbest.kfn:9092,broker2.dahbest.kfn:9092,broker3.dahbest.kfn:9092 \
  --command-config /opt/kafka/config/gssapi-admin-client.properties \
  --create \
  --topic cagri-topic \
  --partitions 12 \
  --replication-factor 3

echo ""