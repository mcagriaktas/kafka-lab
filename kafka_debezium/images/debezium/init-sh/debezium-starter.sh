#!/bin/bash
set -e

sleep 15 

export KAFKA_OPTS="-javaagent:/opt/jmx_exporter/jmx_prometheus_javaagent.jar=8080:/opt/jmx_exporter/connect-metrics.yml"

exec ${KAFKA_HOME}/bin/connect-distributed.sh /opt/kafka/config/connect-distributed.properties