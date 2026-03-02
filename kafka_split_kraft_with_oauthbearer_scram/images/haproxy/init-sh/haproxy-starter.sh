#!/bin/bash

echo "HAProxy is starting..."

echo "Validating HAProxy configuration..."
if ! /usr/local/sbin/haproxy -c -f /opt/haproxy/configs/haproxy.cfg; then
    echo "ERROR: HAProxy configuration validation failed"
    exit 1
fi

echo "HAProxy configuration is valid"

echo "Waiting for backend services to initialize..."
sleep 5

echo "Starting HAProxy in foreground mode..."
exec /usr/local/sbin/haproxy -f /opt/haproxy/configs/haproxy.cfg -W