#!/bin/bash
set -e

sleep 15

export KAFKA_HEAP_OPTS="-Xms2G -Xmx6G"

chmod 777 -R /opt/cruise-control

${CRUISE_CONTROL_HOME}/kafka-cruise-control-start.sh ${CRUISE_CONTROL_HOME}/config/cruisecontrol.properties