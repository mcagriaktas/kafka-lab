#!/bin/bash
set -e 

export KAFKA_HEAP_OPTS="-Xms2g -Xmx8g -XX:+ExitOnOutOfMemoryError"

echo "Kafka Container $HOSTNAME Starting"

/mnt/kafka_2.13-3.7.2/bin/kafka-storage.sh format --config /mnt/properties/kraft_server.properties --cluster-id U2TYzXg8Q2ODk3o0eiW6YQ --ignore-formatted &

tail -f /dev/null