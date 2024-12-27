#!/bin/bash

export KSQL_OPTS="-XX:+UseG1GC"

# Start KSQL server
ksql-server-start /etc/ksqldb/server.properties