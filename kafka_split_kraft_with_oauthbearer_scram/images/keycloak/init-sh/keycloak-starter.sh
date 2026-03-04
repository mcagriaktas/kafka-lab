#!/bin/bash
set -e

echo "Keycloak starter script is running..."

export KC_BOOTSTRAP_ADMIN_USERNAME="$KEYCLOAK_ADMIN"
export KC_BOOTSTRAP_ADMIN_PASSWORD="$KEYCLOAK_ADMIN_PASSWORD"

kafka-token-creater.sh & 

exec /opt/keycloak/bin/kc.sh start-dev \
    --http-port=8080 \
    --https-port=8443 \
    --https-certificate-file=/opt/keycloak/jks/keycloak.crt \
    --https-certificate-key-file=/opt/keycloak/jks/keycloak.key \
    --hostname=https://keycloak.dahbest.kfn:8443 \
    --hostname-strict=false