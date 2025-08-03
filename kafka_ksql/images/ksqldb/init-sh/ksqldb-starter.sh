#!/bin/bash

export KSQL_OPTS="-Xms2g -Xmx6g -XX:MaxRAMPercentage=80.0 -XX:+UseStringDeduplication -XX:+ExitOnOutOfMemoryError"

sleep 10

# Start KSQL server
${KSQL_DIR}/bin/ksql-server-start ${KSQL_DIR}/config/ksqldb.properties