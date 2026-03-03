#!/bin/bash

sleep 15

# Set bootstrap servers based on cluster suffix

BOOTSTRAP_SERVERS="broker1.dahbest.kfn:9092,broker2.dahbest.kfn:9092,broker3.dahbest.kfn:9092"

echo "Bootstrap servers: $BOOTSTRAP_SERVERS"
echo ""

echo "kafka-ui user creating."
/opt/kafka/bin/kafka-configs.sh \
    --bootstrap-server "$BOOTSTRAP_SERVERS" \
    --command-config /opt/kafka/config/oauthbearer-admin-client.properties \
    --alter \
    --add-config "SCRAM-SHA-256=[password=cagri3541]" \
    --entity-type users \
    --entity-name "kafkaui"
    
echo ""

echo "kafka-ui user's ACLS."
/opt/kafka/bin/kafka-acls.sh \
    --bootstrap-server "$BOOTSTRAP_SERVERS" \
    --command-config /opt/kafka/config/oauthbearer-admin-client.properties \
    --add \
    --allow-principal "User:kafkaui" \
    --operation All \
    --topic '*' \
    --group '*' \
    --cluster

echo ""

echo "topic-a topic is creating..."
/opt/kafka/bin/kafka-topics.sh \
  --bootstrap-server "$BOOTSTRAP_SERVERS" \
  --command-config /opt/kafka/config/oauthbearer-admin-client.properties \
  --create \
  --topic cagri-topic \
  --partitions 12 \
  --replication-factor 3

echo ""