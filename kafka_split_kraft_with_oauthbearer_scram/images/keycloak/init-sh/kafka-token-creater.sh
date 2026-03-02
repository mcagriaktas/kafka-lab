#!/bin/bash

echo "Waiting for Keycloak to become available..."

# Ping the master realm quietly (-s) and throw away standard output (>/dev/null)
while ! curl -kfs https://keycloak.dahbest.kfn:8443/realms/master >/dev/null 2>&1; do
  echo "Keycloak not ready yet. Sleeping for 2 seconds..."
  sleep 2
done

echo "Keycloak is up! Creating Kafka clients..."

BROKER_CLIENT_ID="kafka-broker"
CONTROLLER_CLIENT_ID="kafka-controller"
KAFKA_ADMIN_CLIENT_ID="kafka-admin"
SECRET_BROKER="bTCgOCh39yrevYCf60yIuo7WH1heozWN"
SECRET_CONTROLLER="cTCgOCh39yrevYCf60yIuo7WH1heozWN"
SECRET_KAFKA_ADMIN="aTCgOCh39yrevYCf60yIuo7WH1heozWN"
TOKEN_LIFESPAN="1800"

# Fetch Admin Token
ADMIN_TOKEN=$(curl -sk -X POST https://localhost:8443/realms/master/protocol/openid-connect/token \
  -d "grant_type=password" \
  -d "client_id=admin-cli" \
  -d "username=cagri" \
  -d "password=cagri3541" | jq -r .access_token)

for CLIENT_ID in $BROKER_CLIENT_ID $CONTROLLER_CLIENT_ID $KAFKA_ADMIN_CLIENT_ID; do
  echo "--------------------------------------------------"
  echo "Processing client: $CLIENT_ID"

  if [[ $CLIENT_ID == "kafka-broker" ]]; then
    echo "  -> Configured for BROKER with Client Secret: $SECRET_BROKER"
    SECRET=$SECRET_BROKER
  elif [[ $CLIENT_ID == "kafka-controller" ]]; then
    echo "  -> Configured for CONTROLLER with Client Secret: $SECRET_CONTROLLER"
    SECRET=$SECRET_CONTROLLER
  elif [[ $CLIENT_ID == "kafka-admin" ]]; then
    echo "  -> Configured for ADMIN with Client Secret: $SECRET_KAFKA_ADMIN"
    SECRET=$SECRET_KAFKA_ADMIN
  fi

  # Create Kafka Client (sending output to /dev/null to keep console clean)
  curl -sk -X POST https://localhost:8443/admin/realms/master/clients \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
      "clientId": "'$CLIENT_ID'",
      "enabled": true,
      "clientAuthenticatorType": "client-secret",
      "secret": "'$SECRET'",
      "serviceAccountsEnabled": true,
      "publicClient": false,
      "standardFlowEnabled": false,
      "directAccessGrantsEnabled": false,
      "attributes": {
        "access.token.lifespan": "1800"
      }
    }' >/dev/null

  # Fetch newly created Client UUID
  CLIENT_UUID=$(curl -sk "https://localhost:8443/admin/realms/master/clients?clientId=$CLIENT_ID" \
    -H "Authorization: Bearer $ADMIN_TOKEN" | jq -r '.[0].id')

  echo "  -> Client UUID: $CLIENT_UUID"

  # 2. Create Protocol Mapper (If it already exists, Keycloak rejects it, so we suppress the error output)
  curl -sk -X POST "https://localhost:8443/admin/realms/master/clients/$CLIENT_UUID/protocol-mappers/models" \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
      "name": "kafka-audience",
      "protocol": "openid-connect",
      "protocolMapper": "oidc-audience-mapper",
      "consentRequired": false,
      "config": {
        "included.client.audience": "kafka",
        "id.token.claim": "false",
        "access.token.claim": "true"
      }
    }' >/dev/null

  # 3. Test Client Credentials Grant
  echo "  -> Testing token generation..."
  TOKEN_RESPONSE=$(curl -sk -X POST https://localhost:8443/realms/master/protocol/openid-connect/token \
    -d "grant_type=client_credentials" \
    -d "client_id=$CLIENT_ID" \
    -d "client_secret=$SECRET")
  
  # Extract access_token, set to empty if not found
  TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.access_token // empty')

  if [ -n "$TOKEN" ]; then
    echo "  -> Token fetched successfully! Decoded JWT payload:"
    echo "$TOKEN" | cut -d. -f2 | base64 -d 2>/dev/null | jq '{sub, aud, iss}'
  else
    echo "  -> [ERROR] Failed to fetch token. (Does the existing client have a different secret?)"
    echo "  -> API Response: $(echo "$TOKEN_RESPONSE" | jq -c .)"
  fi

done
echo "--------------------------------------------------"