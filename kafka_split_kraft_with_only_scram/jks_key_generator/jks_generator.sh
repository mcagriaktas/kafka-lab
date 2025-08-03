#!/bin/bash

set -e

echo "===== Starting JKS Generator ====="

# Configuration
PASSWORD="cagri3541"
NODE_NAMES=("broker1" "broker2" "broker3" "controller1" "kafka-ui")
KEYSTORE_TYPE="PKCS12"
VALIDITY_DAYS=365
CA_VALIDITY_DAYS=3650
KEY_SIZE=2048
KEYS_DIR="keys"
ROOTS_DIR="roots_keys"

# Create directories
mkdir -p "$KEYS_DIR/client" "$ROOTS_DIR"

# Generate Root CA
echo "====[ Generating Root CA ]===="
if [[ -f "$ROOTS_DIR/rootCA.key" || -f "$ROOTS_DIR/rootCA.crt" ]]; then
    if [[ ! -f "$ROOTS_DIR/rootCA.key" || ! -f "$ROOTS_DIR/rootCA.crt" ]]; then
        echo "Error: Partial Root CA files exist in $ROOTS_DIR. Delete them or check manually."
        exit 1
    fi
    echo "Root CA files already exist in $ROOTS_DIR, skipping generation."
else
    echo "Generating $ROOTS_DIR/rootCA.key"
    openssl genrsa -out "$ROOTS_DIR/rootCA.key" 4096
    echo "Generating $ROOTS_DIR/rootCA.crt"
    openssl req -x509 -new -key "$ROOTS_DIR/rootCA.key" -days "$CA_VALIDITY_DAYS" -out "$ROOTS_DIR/rootCA.crt" \
        -subj "/CN=KafkaRootCA/OU=Kafka/O=Example/L=City/ST=State/C=TR" \
        -passout pass:"$PASSWORD"
fi

# Generate certificates and JKS files
for NODE in "${NODE_NAMES[@]}"; do
    echo ""
    echo "====[ Processing $NODE ]===="

    # Create node directory
    mkdir -p "$KEYS_DIR/$NODE"

    # Check if keystore/truststore already exists
    if [[ -f "$KEYS_DIR/$NODE/$NODE.keystore.jks" || -f "$KEYS_DIR/$NODE/$NODE.truststore.jks" ]]; then
        echo "Warning: Keystore or truststore for $NODE already exists in $KEYS_DIR/$NODE. Skipping."
        continue
    fi

    # 1. Generate keystore and private key
    echo "Creating $NODE's keystore..."
    keytool -genkeypair \
        -alias "$NODE" \
        -keyalg RSA \
        -keysize "$KEY_SIZE" \
        -keystore "$KEYS_DIR/$NODE/$NODE.keystore.jks" \
        -storepass "$PASSWORD" \
        -keypass "$PASSWORD" \
        -dname "CN=$NODE,OU=Kafka,O=Example,L=City,ST=State,C=TR" \
        -ext "SAN=dns:$NODE" \
        -storetype "$KEYSTORE_TYPE"

    # 2. Generate CSR
    echo "Generating CSR for $NODE..."
    keytool -certreq \
        -alias "$NODE" \
        -keystore "$KEYS_DIR/$NODE/$NODE.keystore.jks" \
        -file "$KEYS_DIR/$NODE/$NODE.csr" \
        -storepass "$PASSWORD"

    # 3. Sign CSR with Root CA
    echo "Signing $NODE's certificate with Root CA..."
    openssl x509 -req \
        -CA "$ROOTS_DIR/rootCA.crt" \
        -CAkey "$ROOTS_DIR/rootCA.key" \
        -in "$KEYS_DIR/$NODE/$NODE.csr" \
        -out "$KEYS_DIR/$NODE/$NODE-signed.crt" \
        -days "$VALIDITY_DAYS" \
        -CAcreateserial \
        -passin pass:"$PASSWORD" \
        -extensions v3_req \
        -extfile <(echo -e "[v3_req]\nsubjectAltName=DNS:$NODE")

    # 4. Import Root CA into keystore
    echo "Importing Root CA into $NODE's keystore..."
    keytool -importcert \
        -alias rootCA \
        -file "$ROOTS_DIR/rootCA.crt" \
        -keystore "$KEYS_DIR/$NODE/$NODE.keystore.jks" \
        -storepass "$PASSWORD" \
        -noprompt

    # 5. Import signed certificate into keystore
    echo "Importing $NODE's signed certificate into keystore..."
    keytool -importcert \
        -alias "$NODE" \
        -file "$KEYS_DIR/$NODE/$NODE-signed.crt" \
        -keystore "$KEYS_DIR/$NODE/$NODE.keystore.jks" \
        -storepass "$PASSWORD" \
        -noprompt

    # 6. Create truststore with Root CA
    echo "Creating $NODE's truststore with Root CA..."
    keytool -importcert \
        -alias rootCA \
        -file "$ROOTS_DIR/rootCA.crt" \
        -keystore "$KEYS_DIR/$NODE/$NODE.truststore.jks" \
        -storepass "$PASSWORD" \
        -noprompt \
        -storetype "$KEYSTORE_TYPE"

    # Clean up temporary files
    rm -f "$KEYS_DIR/$NODE/$NODE.csr" "$KEYS_DIR/$NODE/$NODE-signed.crt"
done

# Clean up CA serial file
rm -f "$ROOTS_DIR/rootCA.srl"

# Create client truststore and PEM
echo ""
echo "====[ Creating client truststore and PEM ]===="
if [[ ! -f "$KEYS_DIR/client/client.truststore.jks" ]]; then
    echo "Creating client.truststore.jks..."
    keytool -importcert \
        -alias rootCA \
        -file "$ROOTS_DIR/rootCA.crt" \
        -keystore "$KEYS_DIR/client/client.truststore.jks" \
        -storepass "$PASSWORD" \
        -noprompt \
        -storetype "$KEYSTORE_TYPE"
fi

echo "Creating $KEYS_DIR/client/client.pem..."
cp "$ROOTS_DIR/rootCA.crt" "$KEYS_DIR/client/client.pem"

echo ""
echo "===== Certificate generation completed ====="
echo "Generated files for nodes: ${NODE_NAMES[*]}"
echo "- Keystores: $KEYS_DIR/<node>/<node>.keystore.jks"
echo "- Truststores: $KEYS_DIR/<node>/<node>.truststore.jks (contains Root CA)"
echo "- Client truststore: $KEYS_DIR/client/client.truststore.jks"
echo "- Client PEM: $KEYS_DIR/client/client.pem"
echo "- Root CA: $ROOTS_DIR/rootCA.{crt,key}"
echo "Password for all stores: [HIDDEN]"