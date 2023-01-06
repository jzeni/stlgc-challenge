#!/usr/bin/env bash

kubectl -n kafka \
  exec -it \
  deployment/kafka-broker \
  -- \
  /opt/kafka/bin/kafka-topics.sh --bootstrap-server kafka-broker:9092 --create --if-not-exists --topic dev.pingpong.requested --replication-factor 1 --partitions 1

kubectl -n kafka \
  exec -it \
  deployment/kafka-broker \
  -- \
  /opt/kafka/bin/kafka-topics.sh --bootstrap-server kafka-broker:9092 --create --if-not-exists --topic dev.pingpong.succeeded --replication-factor 1 --partitions 1

kubectl -n kafka \
  exec -it \
  deployment/kafka-broker \
  -- \
  /opt/kafka/bin/kafka-topics.sh --bootstrap-server kafka-broker:9092 --create --if-not-exists --topic dev.pingpong.failed --replication-factor 1 --partitions 1
