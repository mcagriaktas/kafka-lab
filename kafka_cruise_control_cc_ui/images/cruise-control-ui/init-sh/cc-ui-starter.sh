#!/bin/bash

echo "Starting Cruise Control UI..."
sleep 60

nginx -g "daemon off;" &

chmod 777 -R /var/log

tail -f /var/log/nginx/access.log /var/log/nginx/error.log