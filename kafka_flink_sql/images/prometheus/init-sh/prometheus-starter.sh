#!/bin/bash
set -e 

sleep 15 

exec ${PROMETHEUS_HOME}/prometheus \
  --config.file=${PROMETHEUS_HOME}/prometheus.yaml \
  --storage.tsdb.path=/prometheus/data \
  --web.enable-lifecycle \
  --web.enable-admin-api \
  --web.enable-remote-write-receiver \
  --enable-feature=remote-write-receiver


