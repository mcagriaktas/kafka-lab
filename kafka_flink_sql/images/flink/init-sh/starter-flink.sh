#!/bin/bash

if [ -z "$1" ]; then
    echo "No task specified. Please specify 'jobmanager' or 'taskmanager'"
    exit 1
fi

task=$1
echo "Starting Flink $task"

if [ "$task" == "jobmanager" ]; then
    $FLINK_HOME/bin/$task.sh start-foreground &
    sleep 5
    exec $FLINK_HOME/bin/sql-gateway.sh start-foreground
else
    exec $FLINK_HOME/bin/$task.sh start-foreground
fi