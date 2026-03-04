#!/bin/bash

# ====================== CONFIGURATION ======================
BOOTSTRAP_SERVER="broker1.dahbest.kfn:9092,broker2.dahbest.kfn:9092,broker3.dahbest.kfn:9092"

KEYCLOAK_URL="https://keycloak.dahbest.kfn:8443"
TRUSTSTORE_PASS="cagri3541"

get_kafka_opts() {
    local node_name=$1
    echo "-Dorg.apache.kafka.sasl.oauthbearer.allowed.urls=${KEYCLOAK_URL}/realms/master/protocol/openid-connect/token,${KEYCLOAK_URL}/realms/master/protocol/openid-connect/certs \
-Djavax.net.ssl.trustStore=/opt/kafka/config/jks/${node_name}.truststore.jks \
-Djavax.net.ssl.trustStorePassword=${TRUSTSTORE_PASS}"
}

run_kafka_command() {
    local container=$1
    local tool=$2
    shift 2
    local opts=$(get_kafka_opts "$container")
    docker exec -e "KAFKA_OPTS=$opts" "$container" /opt/kafka/bin/"$tool" "$@" 2>&1
}

# ====================== PROGRESS BAR ======================
show_progress() {
    local width=25
    local i=0
    while true; do
        printf "\r["
        for ((j=0; j<i; j++)); do printf "█"; done
        for ((j=i; j<width; j++)); do printf "░"; done
        printf "] %d%%" $((i*100/width))
        i=$(( (i+1) % (width+1) ))
        sleep 0.08
    done
}

stop_progress() {
    kill "$1" 2>/dev/null
    printf "\r["
    for ((i=0; i<25; i++)); do printf "█"; done
    printf "] 100%% [✅]\n"
}

# ====================== FUNCTIONS ======================
list_topics() {
    echo "⚠️  Listing Kafka Topics on both clusters..."
    local container=$(get_container "$BOOTSTRAP_SERVER")
    [[ -z "$container" ]] && continue

    show_progress &
    local PROGRESS_PID=$!

    output=$(run_kafka_command "$container" kafka-topics.sh \
        --bootstrap-server "$BOOTSTRAP_SERVER" \
        --command-config /opt/kafka/config/oauthbearer-admin-client.properties \
        --list)
    exit_code=$?

    stop_progress $PROGRESS_PID

    echo "📍 Cluster: $BOOTSTRAP_SERVER"
    if [ $exit_code -eq 0 ]; then
        echo ""
        echo "$output"
        echo ""
        echo "✅ Topics listed successfully"
    else
        echo "❌ Failed: $output"
    fi
    echo "──────────────────────────────────────────"
}

create_topic() {
    read -p "Topic name: " topic_name
    read -p "Partitions [3]: " partitions
    read -p "Replication factor [2]: " replication_factor

    partitions=${partitions:-3}
    replication_factor=${replication_factor:-2}

    if [ -z "$topic_name" ]; then
        echo "❌ Topic name required"
        return 1
    fi

    echo "⚠️  Creating topic '$topic_name' on both clusters..."
    local container=$(get_container "$BOOTSTRAP_SERVER")
    [[ -z "$container" ]] && continue

    show_progress &
    local PROGRESS_PID=$!

    output=$(run_kafka_command "$container" kafka-topics.sh \
        --bootstrap-server "$BOOTSTRAP_SERVER" \
        --command-config /opt/kafka/config/oauthbearer-admin-client.properties \
        --create --topic "$topic_name" \
        --partitions "$partitions" --replication-factor "$replication_factor")
    exit_code=$?

    stop_progress $PROGRESS_PID

    echo "📍 Cluster: $BOOTSTRAP_SERVER → $( [ $exit_code -eq 0 ] && echo "✅ Created" || echo "❌ Failed" )"

}

create_scram_user() {
    read -p "SCRAM username: " scram_user
    read -s -p "SCRAM password: " scram_password
    echo

    if [ -z "$scram_user" ] || [ -z "$scram_password" ]; then
        echo "❌ Username and password required"
        return 1
    fi

    echo "⚠️  Creating SCRAM User: $scram_user"
    local container=$(get_container "$BOOTSTRAP_SERVER")
    [[ -z "$container" ]] && continue

    show_progress &
    local PROGRESS_PID=$!

    output=$(run_kafka_command "$container" kafka-configs.sh \
        --bootstrap-server "$BOOTSTRAP_SERVER" \
        --command-config /opt/kafka/config/oauthbearer-admin-client.properties \
        --alter --add-config "SCRAM-SHA-256=[password=$scram_password]" \
        --entity-type users --entity-name "$scram_user")
    exit_code=$?

    stop_progress $PROGRESS_PID

    echo "📍 Cluster: $BOOTSTRAP_SERVER → $( [ $exit_code -eq 0 ] && echo "✅ Created" || echo "❌ Failed" )"

}

create_oauthbearer_user() {
    echo "⚠️  Creating OAuth Bearer User (Keycloak Client)..."

    read -p "Keycloak ClientID: " CLIENT_ID
    if [[ -z $CLIENT_ID ]]; then
        echo "❌ Client ID required"
        return 1
    fi

    CLIENT_SECRET=$(tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 32)

    ADMIN_TOKEN=$(curl -sk -X POST "${KEYCLOAK_URL}/realms/master/protocol/openid-connect/token" \
        -d "grant_type=password" -d "client_id=admin-cli" \
        -d "username=cagri" -d "password=cagri3541" | jq -r .access_token)

    curl -sk -X POST "${KEYCLOAK_URL}/admin/realms/master/clients" \
        -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json" \
        -d '{
            "clientId": "'$CLIENT_ID'",
            "enabled": true,
            "protocol": "openid-connect",
            "clientAuthenticatorType": "client-secret",
            "secret": "'$CLIENT_SECRET'",
            "serviceAccountsEnabled": true,
            "publicClient": false,
            "standardFlowEnabled": false,
            "directAccessGrantsEnabled": false,
            "attributes": {"access.token.lifespan": "1800"}
        }' >/dev/null

    CLIENT_UUID=$(curl -sk "${KEYCLOAK_URL}/admin/realms/master/clients?clientId=$CLIENT_ID" \
        -H "Authorization: Bearer $ADMIN_TOKEN" | jq -r '.[0].id')

    curl -sk -X POST "${KEYCLOAK_URL}/admin/realms/master/clients/$CLIENT_UUID/protocol-mappers/models" \
        -H "Authorization: Bearer $ADMIN_TOKEN" -H "Content-Type: application/json" \
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

    TOKEN_RESPONSE=$(curl -sk -X POST "${KEYCLOAK_URL}/realms/master/protocol/openid-connect/token" \
        -d "grant_type=client_credentials" -d "client_id=$CLIENT_ID" -d "client_secret=$CLIENT_SECRET")

    TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.access_token // empty')

    if [ -n "$TOKEN" ]; then
        echo "✅ OAuth Bearer User created!"
        echo "Client ID     : $CLIENT_ID"
        echo "Client Secret : $CLIENT_SECRET"
        echo "⚠️  SAVE THE SECRET NOW — window will close!"
    else
        echo "❌ Failed. Response: $TOKEN_RESPONSE"
    fi
}

list_scram_users() {
    echo "⚠️  Listing SCRAM Users on both clusters..."

    local container=$(get_container "$BOOTSTRAP_SERVER")
    [[ -z "$container" ]] && continue

    show_progress &
    local PROGRESS_PID=$!

    output=$(run_kafka_command "$container" kafka-configs.sh \
        --bootstrap-server "$BOOTSTRAP_SERVER" \
        --command-config /opt/kafka/config/oauthbearer-admin-client.properties \
        --describe --entity-type users)
    exit_code=$?

    stop_progress $PROGRESS_PID

    echo "📍 Cluster: $BOOTSTRAP_SERVER"
    if [ $exit_code -eq 0 ]; then
        echo ""
        echo "$output"
        echo ""
        echo "✅ Listed successfully"
    else
        echo "❌ Failed: $output"
    fi
    echo "──────────────────────────────────────────"

}

describe_topic() {
    read -p "Topic name to describe: " topic_name
    if [ -z "$topic_name" ]; then
        echo "❌ Topic name required"
        return 1
    fi

    echo "⚠️  Describing topic '$topic_name'..."
    local container=$(get_container "$BOOTSTRAP_SERVER")
    [[ -z "$container" ]] && continue

    show_progress &
    local PROGRESS_PID=$!

    output=$(run_kafka_command "$container" kafka-topics.sh \
        --bootstrap-server "$BOOTSTRAP_SERVER" \
        --command-config /opt/kafka/config/oauthbearer-admin-client.properties \
        --describe --topic "$topic_name")
    exit_code=$?

    stop_progress $PROGRESS_PID

    echo "📍 Cluster: $BOOTSTRAP_SERVER"
    if [ $exit_code -eq 0 ]; then
        echo ""
        echo "$output"
        echo ""
        echo "✅ Described successfully"
    else
        echo "❌ Failed: $output"
    fi

}

add_acls() {
    read -p "Principal (User:name): " principal
    read -p "Topic (* for all): " topic_name
    read -p "Operation (All/Read/Write/...): " operation

    if [ -z "$principal" ] || [ -z "$topic_name" ] || [ -z "$operation" ]; then
        echo "❌ All fields required"
        return 1
    fi

    # Add User: prefix if not already present
    if [[ ! "$principal" =~ ^[A-Za-z]+: ]]; then
        principal="User:$principal"
    fi

    echo "⚠️  Adding ACL..."
    local container=$(get_container "$BOOTSTRAP_SERVER")
    [[ -z "$container" ]] && continue

    show_progress &
    local PROGRESS_PID=$!

    output=$(run_kafka_command "$container" kafka-acls.sh \
        --bootstrap-server "$BOOTSTRAP_SERVER" \
        --command-config /opt/kafka/config/oauthbearer-admin-client.properties \
        --add --allow-principal "$principal" --operation "$operation" --topic "$topic_name" 2>&1)
    exit_code=$?

    stop_progress $PROGRESS_PID

    if [ $exit_code -eq 0 ]; then
        echo "📍 Cluster: $BOOTSTRAP_SERVER → ✅ Added"
    else
        echo "📍 Cluster: $BOOTSTRAP_SERVER → ❌ Failed"
        echo "Error details: $output"
    fi

}

list_acls() {
    echo "⚠️  Listing ACLs on both clusters..."
    local container=$(get_container "$BOOTSTRAP_SERVER")
    [[ -z "$container" ]] && continue

    show_progress &
    local PROGRESS_PID=$!

    output=$(run_kafka_command "$container" kafka-acls.sh \
        --bootstrap-server "$BOOTSTRAP_SERVER" \
        --command-config /opt/kafka/config/oauthbearer-admin-client.properties \
        --list)
    exit_code=$?

    stop_progress $PROGRESS_PID

    echo "📍 Cluster: $BOOTSTRAP_SERVER"
    if [ $exit_code -eq 0 ]; then
        [ -z "$output" ] && echo "No ACLs found." || echo "$output"
        echo "✅ Listed successfully"
    else
        echo "❌ Failed: $output"
    fi

}

add_consumer_group_acls() {
    read -p "Principal (User:name): " principal
    read -p "Consumer Group (* for all): " group_id

    if [ -z "$principal" ] || [ -z "$group_id" ]; then
        echo "❌ All fields required"
        return 1
    fi

    if [[ ! "$principal" =~ ^[A-Za-z]+: ]]; then
        principal="User:$principal"
    fi

    echo "⚠️  Adding Consumer Group ACL..."
    local container=$(get_container "$BOOTSTRAP_SERVER")
    [[ -z "$container" ]] && continue

    show_progress &
    local PROGRESS_PID=$!

    output=$(run_kafka_command "$container" kafka-acls.sh \
        --bootstrap-server "$BOOTSTRAP_SERVER" \
        --command-config /opt/kafka/config/oauthbearer-admin-client.properties \
        --add --allow-principal "$principal" --operation Read --group "$group_id" 2>&1)
    exit_code=$?

    stop_progress $PROGRESS_PID

    if [ $exit_code -eq 0 ]; then
        echo "📍 Cluster: $BOOTSTRAP_SERVER → ✅ Added"
    else
        echo "📍 Cluster: $BOOTSTRAP_SERVER → ❌ Failed"
        echo "Error details: $output"
    fi

}

show_menu() {
    clear
    echo "╔════════════════════════════════════════════╗"
    echo "║       Kafka Cluster Manager (OAuth)        ║"
    echo "╚════════════════════════════════════════════╝"
    echo ""
    echo "1) Create Topic"
    echo "2) List Topics"
    echo "3) Describe Topic"
    echo "4) Create SCRAM User"
    echo "5) Create OAuth Bearer User"
    echo "6) List SCRAM Users"
    echo "7) Add ACL"
    echo "8) List ACLs"
    echo "9) Add Consumer Group ACL"
    echo "10) Exit"
    echo ""
    read -p "Choose [1-10]: " choice
}

# ====================== MAIN LOOP ======================
while true; do
    show_menu

    case $choice in
        1) create_topic ;;
        2) list_topics ;;
        3) describe_topic ;;
        4) create_scram_user ;;
        5) create_oauthbearer_user ;;
        6) list_scram_users ;;
        7) add_acls ;;
        8) list_acls ;;
        9) add_consumer_group_acls ;;
        10)
            echo "Goodbye! 👋"
            exit 0
            ;;
        *)
            echo "❌ Invalid option"
            ;;
    esac

    echo -e "\nPress Enter to continue..."
    read
done