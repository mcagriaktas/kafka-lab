#!/bin/bash
set -e

export KAFKA_HEAP_OPTS="-Xms2g -Xmx8g -XX:+ExitOnOutOfMemoryError"

sleep 5

${KAFKA_HOME}/bin/kafka-server-start.sh ${KAFKA_HOME}/config/server.properties