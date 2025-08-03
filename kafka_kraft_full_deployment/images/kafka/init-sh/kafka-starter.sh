#!/bin/bash
set -e

export KAFKA_HEAP_OPTS="-Xms2g -Xmx6g -XX:+ExitOnOutOfMemoryError"
export KAFKA_JMX_OPTS="-javaagent:${JMX_EXPORTER_HOME}/jmx_prometheus_javaagent.jar=7071:${JMX_EXPORTER_HOME}/kafka-metrics.yml"

${KAFKA_HOME}/bin/kafka-storage.sh format --config ${KAFKA_HOME}/config/server.properties --cluster-id 'EP6hyiddQNW5FPrAvR9kWw' --ignore-formatted

if [[ $HOSTNAME == "kafka1" ]]; then
    exec kafka-export-starter.sh &
fi

exec ${KAFKA_HOME}/bin/kafka-server-start.sh ${KAFKA_HOME}/config/server.properties