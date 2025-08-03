#!/bin/bash

sleep 30

java --add-opens java.rmi/javax.rmi.ssl=ALL-UNNAMED -Dspring.config.additional-location=/opt/config.yml -jar /opt/kafka-ui-api-v0.7.2.jar