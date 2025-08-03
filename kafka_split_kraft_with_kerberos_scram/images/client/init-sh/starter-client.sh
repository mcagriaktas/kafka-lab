#!/bin/bash

echo "The container only includes the client side, so you can't use localhost to connect to the broker. For this reason, you need to configure all your clients inside the container."

tail -f /dev/null