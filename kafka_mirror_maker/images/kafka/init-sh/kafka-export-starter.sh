#!/bin/bash

set -e 

sleep 15

current_hostname=$(hostname)

if [[ $current_hostname == "kafka1-a" ]]; then
    echo "Starting Kafka Exporter..."
    exec ${KAFKA_EXPORTER_HOME}/kafka_exporter \
    --kafka.server=kafka1-a:9092 --kafka.server=kafka2-a:9092 --kafka.server=kafka3-a:9092 \
    --web.listen-address=:9308 \
    --web.telemetry-path=/metrics \
    --topic.filter=.* \
    --group.filter=.* \
    --log.level=info
elif [[ $current_hostname == "kafka1-b" ]]; then
    echo "Starting Kafka Exporter..."
    exec ${KAFKA_EXPORTER_HOME}/kafka_exporter \
    --kafka.server=kafka1-b:9092 --kafka.server=kafka2-b:9092 --kafka.server=kafka3-b:9092 \
    --web.listen-address=:9309 \
    --web.telemetry-path=/metrics \
    --topic.filter=.* \
    --group.filter=.* \
    --log.level=info
else
    echo " == ERROR ======= kafka-export-starter.sh ======= ERORR == "
fi