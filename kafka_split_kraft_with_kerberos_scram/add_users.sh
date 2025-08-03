#!/bin/bash

check_broker() {
    if ! docker ps | grep -q "broker"; then
        echo "❌ Broker container is not running..."
        echo "Use 'docker-compose up -d --build or use ./init-docker-compose.sh' to start the containers"
        exit 1
    fi
    echo "Broker container found"
    return 0
}

# Explicitly call the function
check_broker

show_progress() {
    local width=20
    local i=0
    while true; do
        printf "\r["
        for ((j=0; j<i; j++)); do
            printf "."
        done
        printf " %% %d " $((i*100/width))
        for ((j=i; j<width; j++)); do
            printf "."
        done
        printf "]"
        i=$(( (i+1) %(width+1) ))
        sleep 0.1
    done
}

stop_progress() {
    kill $1 >/dev/null 2>&1
    local width=20
    printf "\r["
    for ((i=0; i<width; i++)); do
        printf "."
    done
    printf " %% 100 "
    for ((i=0; i<width; i++)); do
        printf "."
    done
    printf "] [✅]\n"
}

list_topics() {
    echo "⚠️ Listing Kafka Topics"
    show_progress &
    PROGRESS_PID=$!

    echo "Current topics:"
    if topics=$(docker exec broker /opt/kafka/bin/kafka-topics.sh --bootstrap-server broker:9092 \
        --command-config /opt/kafka/config/kraft/admin-client.properties \
        --list 2>&1); then
        echo "$topics"
        stop_progress $PROGRESS_PID
        echo "✅ Topics listed successfully"
    else
        stop_progress $PROGRESS_PID
        echo "❌ Failed to list topics: $topics"
    fi
    echo ""
}

create_topic() {
    read -p "Please enter the topic name: " topic_name
    read -p "Please enter number of partitions [1]: " partitions
    read -p "Please enter replication factor [1]: " replication_factor
    
    # Set defaults if empty
    partitions=${partitions:-1}
    replication_factor=${replication_factor:-1}
    
    if [ -z "$topic_name" ]; then
        echo "❌ Topic name cannot be empty"
        return 1
    fi

    echo "⚠️ Creating Kafka Topic: $topic_name with $partitions partition(s) and replication factor $replication_factor"
    show_progress &
    PROGRESS_PID=$!

    if output=$(docker exec broker /opt/kafka/bin/kafka-topics.sh --bootstrap-server broker:9092 \
        --command-config /opt/kafka/config/kraft/admin-client.properties \
        --create \
        --topic "$topic_name" \
        --partitions "$partitions" \
        --replication-factor "$replication_factor" 2>&1); then
        stop_progress $PROGRESS_PID
        echo "✅ Topic $topic_name created successfully"
    else
        stop_progress $PROGRESS_PID
        echo "❌ Failed to create topic $topic_name: $output"
    fi
    echo ""
}

create_keytab() {
    read -p "Please enter the principal name: " principle
    read -p "Please enter the hostname: " hostname

    if [ -z "$principle" ] || [ -z "$hostname" ]; then
        echo "❌ Principal and hostname cannot be empty"
        return 1
    fi

    echo "⚠️ Creating Keytab for $principle/$hostname"
    show_progress &
    PROGRESS_PID=$!

    if output=$(docker exec kerberos kadmin.local -q "addprinc -randkey $principle/$hostname@EXAMPLE.COM" 2>&1) && \
       output2=$(docker exec kerberos kadmin.local -q "ktadd -k /keytabs/client-keytabs/$principle-$hostname.keytab $principle/$hostname@EXAMPLE.COM" 2>&1); then
        stop_progress $PROGRESS_PID
        echo "✅ Keytab created successfully"
    else
        stop_progress $PROGRESS_PID
        echo "❌ Failed to create keytab: $output $output2"
    fi
    echo ""
}

create_scram_user() {
    read -p "Please enter SCRAM username: " scram_user
    read -s -p "Please enter SCRAM password: " scram_password
    echo  # Add a newline after hidden password input

    if [ -z "$scram_user" ] || [ -z "$scram_password" ]; then
        echo "❌ Username and password cannot be empty"
        return 1
    fi

    echo "⚠️ Creating SCRAM User: $scram_user"
    show_progress &
    PROGRESS_PID=$!

    # Capture the output but don't display it yet
    output=$(docker exec broker /opt/kafka/bin/kafka-configs.sh \
        --bootstrap-server broker:9092 \
        --command-config /opt/kafka/config/kraft/admin-client.properties \
        --alter \
        --add-config "SCRAM-SHA-256=[password=$scram_password]" \
        --entity-type users \
        --entity-name "$scram_user" 2>&1)
    docker_exit_code=$?
    
    # Stop the progress bar first
    stop_progress $PROGRESS_PID
    
    # Now display the output
    if [ $docker_exit_code -eq 0 ]; then
        echo "✅ SCRAM user $scram_user created successfully"
    else
        echo "$output"
        echo "❌ Failed to create SCRAM user:"
    fi
    echo ""
}

list_scram_users() {
    echo "⚠️ Listing SCRAM Users"
    show_progress &
    PROGRESS_PID=$!

    # Capture the output but don't display it yet
    output=$(docker exec broker /opt/kafka/bin/kafka-configs.sh \
        --bootstrap-server broker:9092 \
        --command-config /opt/kafka/config/kraft/admin-client.properties \
        --describe \
        --entity-type users 2>&1)
    docker_exit_code=$?
    
    # Stop the progress bar first
    stop_progress $PROGRESS_PID
    
    # Now display the output
    if [ $docker_exit_code -eq 0 ]; then
        echo "$output"
        echo "✅ SCRAM users listed successfully"
    else
        echo "$output"
        echo "❌ Failed to list SCRAM users"
    fi
    echo ""
}

add_consumer_group_acls() {
    read -p "Please enter the principal name (format: User:name): " principal
    read -p "Please enter the consumer group ID: " group_id

    if [ -z "$principal" ] || [ -z "$group_id" ]; then
        echo "❌ Principal and group ID cannot be empty"
        return 1
    fi

    echo "⚠️ Adding Consumer Group ACL for $principal on group $group_id"
    show_progress &
    PROGRESS_PID=$!

    if output=$(docker exec broker /opt/kafka/bin/kafka-acls.sh --bootstrap-server broker:9092 \
        --command-config /opt/kafka/config/kraft/admin-client.properties \
        --add \
        --allow-principal "User:$principal" \
        --operation READ \
        --group "$group_id" 2>&1); then
        stop_progress $PROGRESS_PID
        echo "$output"
        echo "✅ Consumer Group ACL added successfully"
    else
        stop_progress $PROGRESS_PID
        echo "❌ Failed to add Consumer Group ACL: $output"
    fi
    echo ""
}

describe_topic() {
    read -p "Please enter the topic name to describe: " topic_name
    if [ -z "$topic_name" ]; then
        echo "❌ Topic name cannot be empty"
        return 1
    fi

    echo "⚠️ Describing Topic: $topic_name"
    show_progress &
    PROGRESS_PID=$!

    if output=$(docker exec broker /opt/kafka/bin/kafka-topics.sh --bootstrap-server broker:9092 \
        --command-config /opt/kafka/config/kraft/admin-client.properties \
        --describe \
        --topic "$topic_name" 2>&1); then
        echo "$output"
        stop_progress $PROGRESS_PID
        echo "✅ Topic described successfully"
    else
        stop_progress $PROGRESS_PID
        echo "❌ Failed to describe topic: $output"
    fi
    echo ""
}

add_acls() {
    read -p "Please enter the principal name (format: User:name): " principal
    read -p "Please enter the topic name: " topic_name
    read -p "Please enter the operation (ALL, READ, WRITE, CREATE, DELETE, ALTER, DESCRIBE): " operation

    if [ -z "$principal" ] || [ -z "$topic_name" ] || [ -z "$operation" ]; then
        echo "❌ Principal, topic name, and operation cannot be empty"
        return 1
    fi

    echo "⚠️ Adding ACL for $principal on topic $topic_name with operation $operation"
    show_progress &
    PROGRESS_PID=$!

    if output=$(docker exec broker /opt/kafka/bin/kafka-acls.sh --bootstrap-server broker:9092 \
        --command-config /opt/kafka/config/kraft/admin-client.properties \
        --add \
        --allow-principal "User:$principal" \
        --operation "$operation" \
        --topic "$topic_name" 2>&1); then
        stop_progress $PROGRESS_PID
        echo "$output"
        echo "✅ ACL added successfully"
    else
        stop_progress $PROGRESS_PID
        echo "❌ Failed to add ACL: $output"
    fi
    echo ""
}

list_acls() {
    echo "⚠️ Listing All ACLs"
    show_progress &
    PROGRESS_PID=$!

    # Execute the command to list all ACLs
    if output=$(docker exec broker /opt/kafka/bin/kafka-acls.sh --bootstrap-server broker:9092 \
        --command-config /opt/kafka/config/kraft/admin-client.properties \
        --list 2>&1); then
        stop_progress $PROGRESS_PID
        if [ -z "$output" ]; then
            echo "No ACLs found."
        else
            echo "$output"
        fi
        echo "✅ ACLs listed successfully"
    else
        stop_progress $PROGRESS_PID
        echo "❌ Failed to list ACLs: $output"
    fi
    echo ""
}


show_menu() {
    echo "╔════════════════════════════════════════╗"
    echo "║    Welcome to Kafka Topic Manager      ║"
    echo "╚════════════════════════════════════════╝"
    echo "1) Create Topic"
    echo "2) Create Keytab (Kafka User)"
    echo "3) List Topics"
    echo "4) Describe Topic"
    echo "5) Create SCRAM User"
    echo "6) List SCRAM Users"
    echo "7) Add ACL"
    echo "8) List ACL"
    echo "9) Add Consumer Group ACL"
    echo "10) Exit"
    echo ""
    read -p "Please enter your choice [1-10]: " choice
}

while true; do
    show_menu

    case $choice in
        1)
            create_topic
            ;;
        2)
            create_keytab
            ;;
        3)
            list_topics
            ;;
        4)
            describe_topic
            ;;
        5)
            create_scram_user
            ;;
        6)
            list_scram_users
            ;;
        7)
            add_acls
            ;;
        8)
            list_acls
            ;;
        9)
            add_consumer_group_acls
            ;;
        10)
            echo "Goodbye! 👋"
            exit 0
            ;;
        *)
            echo "❌ Invalid option. Please try again."
            ;;
    esac

    echo "Press Enter to continue..."
    read
    clear
done