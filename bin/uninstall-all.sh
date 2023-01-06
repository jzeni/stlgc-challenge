#!/usr/bin/env bash

helm uninstall -n kafka kafka
helm uninstall -n microservice microservice
