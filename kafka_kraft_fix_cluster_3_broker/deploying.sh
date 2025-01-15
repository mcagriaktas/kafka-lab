#!/bin/bash

docker-compose up -d --build

sleep 15

docker-compose down

sleep 2

sudo chmod -R 777 -R data_logs
