#!/bin/bash

set -e 

# Start Prometheus with all configurations
exec ${PROMETHEUS_HOME}/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/prometheus/data \
  --web.enable-lifecycle \
  --web.enable-admin-api \
  --web.enable-remote-write-receiver \
  --enable-feature=remote-write-receiver