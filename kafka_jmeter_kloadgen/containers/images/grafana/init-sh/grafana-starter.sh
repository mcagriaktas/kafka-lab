#!/bin/bash
set -e

echo "Starting Grafana initialization..."

export GF_SECURITY_ADMIN_USER="${ADMIN_USER}"
export GF_SECURITY_ADMIN_PASSWORD="${ADMIN_PASSWORD}"
export GF_PATHS_DATA="/opt/grafana/data"
export GF_PATHS_LOGS="/opt/grafana/logs"
export GF_PATHS_PROVISIONING="/opt/grafana/provisioning"

exec /opt/grafana/bin/grafana-server \
    --homepath=/opt/grafana \
    --config=/opt/grafana/confs/grafana.ini \
    "$@"  