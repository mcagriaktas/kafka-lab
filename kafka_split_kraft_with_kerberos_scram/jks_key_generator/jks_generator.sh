#!/bin/bash
set -e

echo "===== Starting JKS Generator ====="

# ----------------------------
# Configuration
# ----------------------------
PASSWORD="cagri3541"
NODE_NAMES=("broker1" "broker2" "broker3" "controller1" "controller2" "controller3" "kafka-ui")
DNS_NAME="dahbest.kfn"
KEYSTORE_TYPE="PKCS12"
VALIDITY_DAYS=3650
CA_VALIDITY_DAYS=3650
KEY_SIZE=2048
KEYS_DIR="keys"
ROOTS_DIR="roots_keys"

# ----------------------------
# Directory Setup
# ----------------------------
mkdir -p "$KEYS_DIR/client" "$ROOTS_DIR"

# ----------------------------
# Root CA Generation
# ----------------------------
echo "====[ Generating Root CA ]===="
if [[ -f "$ROOTS_DIR/rootCA.key" && -f "$ROOTS_DIR/rootCA.crt" ]]; then
    echo "Root CA already exists in $ROOTS_DIR, skipping..."
else
    echo "Generating Root CA key and certificate..."
    openssl genrsa -out "$ROOTS_DIR/rootCA.key" 4096
    openssl req -x509 -new -key "$ROOTS_DIR/rootCA.key" -days "$CA_VALIDITY_DAYS" \
        -out "$ROOTS_DIR/rootCA.crt" \
        -subj "/CN=KafkaRootCA/OU=Kafka/O=Example/L=City/ST=State/C=TR" \
        -passout pass:"$PASSWORD"
fi

# ----------------------------
# Node Certificates
# ----------------------------
for NODE in "${NODE_NAMES[@]}"; do
    echo ""
    echo "====[ Processing $NODE ]===="
    mkdir -p "$KEYS_DIR/$NODE"

    # 1️⃣ Generate private key + keystore
    echo "Creating keystore for $NODE..."
    keytool -genkeypair \
        -alias "$NODE" \
        -keyalg RSA \
        -keysize "$KEY_SIZE" \
        -keystore "$KEYS_DIR/$NODE/$NODE.keystore.jks" \
        -storepass "$PASSWORD" \
        -keypass "$PASSWORD" \
        -dname "CN=$NODE,OU=Kafka,O=Example,L=City,ST=State,C=TR" \
        -ext "SAN=dns:$NODE,dns:$NODE.$DNS_NAME" \
        -storetype "$KEYSTORE_TYPE"

    # 2️⃣ Generate CSR
    echo "Generating CSR for $NODE..."
    keytool -certreq \
        -alias "$NODE" \
        -keystore "$KEYS_DIR/$NODE/$NODE.keystore.jks" \
        -file "$KEYS_DIR/$NODE/$NODE.csr" \
        -storepass "$PASSWORD"

    # 3️⃣ Sign CSR with Root CA (include both DNS and FQDN)
    echo "Signing $NODE certificate with Root CA..."
    openssl x509 -req \
        -CA "$ROOTS_DIR/rootCA.crt" \
        -CAkey "$ROOTS_DIR/rootCA.key" \
        -in "$KEYS_DIR/$NODE/$NODE.csr" \
        -out "$KEYS_DIR/$NODE/$NODE-signed.crt" \
        -days "$VALIDITY_DAYS" \
        -CAcreateserial \
        -passin pass:"$PASSWORD" \
        -extensions v3_req \
        -extfile <(echo -e "[v3_req]\nsubjectAltName=DNS:$NODE,DNS:$NODE.$DNS_NAME")

    # 4️⃣ Import Root CA into keystore
    echo "Importing Root CA into keystore..."
    keytool -importcert \
        -alias rootCA \
        -file "$ROOTS_DIR/rootCA.crt" \
        -keystore "$KEYS_DIR/$NODE/$NODE.keystore.jks" \
        -storepass "$PASSWORD" \
        -noprompt

    # 5️⃣ Import signed node certificate
    echo "Importing signed certificate..."
    keytool -importcert \
        -alias "$NODE" \
        -file "$KEYS_DIR/$NODE/$NODE-signed.crt" \
        -keystore "$KEYS_DIR/$NODE/$NODE.keystore.jks" \
        -storepass "$PASSWORD" \
        -noprompt

    # 6️⃣ Create truststore
    echo "Creating truststore for $NODE..."
    keytool -importcert \
        -alias rootCA \
        -file "$ROOTS_DIR/rootCA.crt" \
        -keystore "$KEYS_DIR/$NODE/$NODE.truststore.jks" \
        -storepass "$PASSWORD" \
        -noprompt \
        -storetype "$KEYSTORE_TYPE"

    # Cleanup
    rm -f "$KEYS_DIR/$NODE/$NODE.csr" "$KEYS_DIR/$NODE/$NODE-signed.crt"
done

# ----------------------------
# Client Truststore and PEM
# ----------------------------
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

echo "Creating client PEM..."
cp "$ROOTS_DIR/rootCA.crt" "$KEYS_DIR/client/client.pem"

# ----------------------------
# Cleanup
# ----------------------------
rm -f "$ROOTS_DIR/rootCA.srl"

# ----------------------------
# Summary
# ----------------------------
echo ""
echo "===== Certificate generation completed ====="
echo "Generated for: ${NODE_NAMES[*]}"
echo "- Keystores: $KEYS_DIR/<node>/<node>.keystore.jks"
echo "- Truststores: $KEYS_DIR/<node>/<node>.truststore.jks"
echo "- Client PEM: $KEYS_DIR/client/client.pem"
echo "- Root CA: $ROOTS_DIR/rootCA.{crt,key}"
echo "Password for all stores: [HIDDEN]"
echo "DNS added: DNS:<node>, DNS:<node>.$DNS_NAME"
