#!/bin/bash
set -e

# Wait until service is available
# Script source: https://github.com/vishnubob/wait-for-it
/home/microservice/wait-for-it.sh -t 60 $BROKER_ADDRESS

# Sleep 10 seconds to wait for automatic topic creation (development only)
sleep 10s

exec "$@"
