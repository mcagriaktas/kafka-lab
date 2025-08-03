#!/bin/bash

echo "Kafka Container is starting..."

export KAFKA_HEAP_OPTS="-Xms2g -Xmx6g -XX:+ExitOnOutOfMemoryError"

tail -f /dev/null