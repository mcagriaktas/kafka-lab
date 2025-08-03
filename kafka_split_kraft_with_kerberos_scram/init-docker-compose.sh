#!/bin/bash

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

check_command() {
    if ! command -v "$1" &> /dev/null; then
        stop_progress $2
        echo "❌ $1 is not installed. Please install $1 first."
        exit 1
    fi
}

echo "⚠️ Checking requirements..."
show_progress &
PROGRESS_PID=$!

check_command "docker" $PROGRESS_PID
check_command "docker-compose" $PROGRESS_PID

stop_progress $PROGRESS_PID
echo "✅ All required tools are installed"
echo ""

echo "⚠️ Creating Docker Network of Dahbest"
show_progress &
PROGRESS_PID=$!

if ! docker network inspect dahbest >/dev/null 2>&1; then
    if docker network create --subnet=172.80.0.0/16 dahbest >/dev/null 2>&1; then
        stop_progress $PROGRESS_PID
        echo "✅ Docker Network Dahbest created"
    else
        stop_progress $PROGRESS_PID
        echo "❌ Failed to create Docker network Dahbest"
        exit 1
    fi
else
    stop_progress $PROGRESS_PID
    echo "✅ Docker Network Dahbest already exists"
fi
echo ""

echo "⚠️ Creating logs directory"
show_progress &
PROGRESS_PID=$!

mkdir -p logs/{broker,controller}/{logs,metadata} logs/kerberos
mkdir -p configs/keytabs/{kafka-keytabs,client-keytabs}
mkdir -p configs/kafka/kafka-keys

if [ ! -d "$(pwd)/logs/broker/logs" ] || \
   [ ! -d "$(pwd)/logs/broker/metadata" ] || \
   [ ! -d "$(pwd)/logs/controller/logs" ] || \
   [ ! -d "$(pwd)/logs/controller/metadata" ] || \
   [ ! -d "$(pwd)/logs/kerberos" ] || \
   [ ! -d "$(pwd)/configs/kafka/kafka-keys" ] || \
   [ ! -d "$(pwd)/configs/keytabs/kafka-keytabs" ] || \
   [ ! -d "$(pwd)/configs/keytabs/client-keytabs" ]; then
   stop_progress $PROGRESS_PID
   echo "❌ Logs directory is not created"
   exit 1
else
    stop_progress $PROGRESS_PID
    
    echo "⚠️ Need sudo privileges to set permissions. Please enter your password:"
    
    sudo -p "Password: " true
    
    sudo chmod -R 777 logs
    sudo chmod -R 777 configs
    
    echo "✅ Logs and Volumes Path directory is created"
fi