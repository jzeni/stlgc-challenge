#!/usr/bin/env bash

helm upgrade microservice \
  --namespace microservice \
  --create-namespace \
  src/helm \
  --install
