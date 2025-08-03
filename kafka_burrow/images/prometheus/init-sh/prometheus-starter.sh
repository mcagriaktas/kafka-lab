#!/bin/bash

set -e 

echo "Prometheus is starting"
${PROMETHEUS_HOME}/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/prometheus/data \
  --web.enable-lifecycle \
  --web.enable-admin-api \
  --web.enable-remote-write-receiver \
  --enable-feature=remote-write-receiver