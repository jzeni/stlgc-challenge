#!/usr/bin/env bash

set -e

KAFKA_ADDRESS="false"

while getopts k: option; do
    case "${option}" in
        k) KAFKA_ADDRESS=${OPTARG};;
    esac
done

USAGE="usage: deploy-microservice.sh -k <kafka address>"

if [ $KAFKA_ADDRESS = "false" ]; then echo "Must supply the kafka IP with -k flag" ; echo $USAGE ; exit 1 ; fi


helm upgrade microservice \
  --namespace microservice \
  --create-namespace \
  microservice/helm \
  --set kafkaAddress=$KAFKA_ADDRESS \
  --install
