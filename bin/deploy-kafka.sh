#!/usr/bin/env bash

helm upgrade kafka \
  --namespace kafka \
  --create-namespace \
  kafka \
  --install

