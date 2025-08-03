#!/bin/bash
set -e

export KAFKA_HEAP_OPTS="-Xms2g -Xmx6g -XX:+ExitOnOutOfMemoryError"

${KAFKA_HOME}/bin/kafka-storage.sh format --config ${KAFKA_HOME}/config/server.properties --cluster-id 'EP6hyiddQNW5FPrAvR9kWw' --ignore-formatted

${KAFKA_HOME}/bin/kafka-server-start.sh ${KAFKA_HOME}/config/server.properties &

sleep 5

if [[ $(hostname) == "kafka1" ]]; then
    /opt/kafka/bin/kafka-topics.sh --create --topic cagri-topic --bootstrap-server kafka1:9092,kafka2:9092,kafka3:9092 --partitions 3 --replication-factor 2 --config min.insync.replicas=2 &
    /opt/kafka/bin/kafka-console-consumer.sh --topic cagri-topic --bootstrap-server kafka1:9092,kafka2:9092,kafka3:9092 --from-beginning --group cagri-group &
fi

tail -f /opt/kafka/logs/server.log