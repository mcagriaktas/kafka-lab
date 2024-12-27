#!/bin/bash

docker-compose up -d --build

sleep 30

docker-compose down

sleep 2

sudo chown -R 777 -R data_logs/
