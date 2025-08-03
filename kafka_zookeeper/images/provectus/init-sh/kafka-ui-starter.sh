#!/bin/bash

sleep 15 

java -Dspring.config.additional-location=/mnt/config.yml -jar /mnt/kafka-ui-api-v0.7.2.jar