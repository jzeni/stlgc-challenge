# Stlgc Challenge

Proof of concept of a python Kafka consumer/producer.

This repository includes:
- The python microservice code,
- docker-compose orchestration to setup services locally for development purposes (microservice, kafka, zookeper),
- a Github Actions pipeline to build the docker image automatically,
- a Helm chart to deploy the microservice and kafka services in a K8s cluster (tested in minikube)

This is a minimal implementation designed to satisfy the basic requirements and to be validated quickly and without much effort.

### Instructions for local setup
To run services locally with docker and docker-compose, use the following command
```
docker-compose up
```
To send events to be processed by the microservice, you can use the CLI from the kafka container  with the services running.
1) `docker-compose exec  kafka bash`
2)  `/bin/kafka-console-producer --topic dev.pingpong.requested --bootstrap-server localhost:9092`

Example log:
```
$ docker-compose logs -f microservice

Attaching to satellogic-challenge_microservice_1
microservice_1  | wait-for-it.sh: waiting 60 seconds for kafka:9092
microservice_1  | wait-for-it.sh: kafka:9092 is available after 9 seconds

microservice_1  | DEBUG:root:Received message: b'invalid-message'
microservice_1  | DEBUG:root:Response: {"message": "Error in the format of the Kafka event"}, Topic: dev.pingpong.failed
```

### Instructions for deployment to Kubernetes

The following instructions deploys the microservice and the kafka and Zookper services.

1) Deploy the Kafka broker and Zookeper using the Helm chart

```
./bin/deploy-kafka.sh
```

2) Create topics
```
./bin/create-topics.sh
```
4) Obtain the Kafka service IP
```
kubectl -n kafka get service kafka-service
```

5) Deploy the microservice
```
./bin/deploy-microservice -k [KAFKA SERVICE IP]
```

## Cloud architecture review
The following is a proposal for a cloud-native architecture based in the AWS platform. All the resources can be created used Terraform as IaC tool.

![aws diagram](https://github.com/jzeni/stlgc-challenge/blob/master/doc/images/aws-diagram.png?raw=true)

High-availability considerations:

 - Networking:
	 - Kubernetes (EKS) cluster should be deployed to multiple AZs.
	 - Nodes should run in private subnets.
	 - In case external connectivity is required a NAT gateway and/or and Internet Gateway should .be used
 - Redundancy:
	 - Replication at pod and node levels is required for fault-tolerance.
	 - Cluster autoscaler and Horizontal Pod Autoscaler (HPA) can be used for auto-scaling.

## Monitoring

Technologies:
- Grafana: used to create graphs and charts for better visibility of the collected data.
- Prometheus: used to process and store metrics.
- JMX exporter: used to extract and export metrics to the Prometheus instance.

Kafka metrics can be broken down into three categories:

 1. Kafka server (broker) metrics
 2. Producer and Consumer metrics (the microservice)
 4. Zookeper metrics

Each category has hundrers of metrics that provides information about the health of the service.
In the following sections, selected key metrics will be listed for each component with a short justification. This is a reduced list of metrics that are considered important and that are necessary to detect performance and/or availability problems of the services.

### 1) Kafka server (broker) metrics

- **Host-level Broker metrics:**
	- `Disk usage`: Because Kafka persists all data to disk, it is necessary to monitor the amount of free disk space available to Kafka.
	- `CPU usage`: Spikes in CPU utilization are sometimes sympthoms of inefficiency.
	- `Network bytes sent/received`: High network usage could be a symptom of degraded performance.
- **Kafka-emitted metrics**
	- `ActiveControllerCount`: The sum of ActiveControllerCount across all the brokers should always equal one, and administrators should alerted on any other value.
	-  `OfflinePartitionsCount`: This metric reports the number of partitions without an active leader. Because all read and write operations are only performed on partition leaders, administrator should be alerted on a non-zero value for this metric to prevent service interruptions.
- JVM metrics:
	- `Garbage collection metrics`: Kafka relies on Java garbage collection processes to free up memory

### 2) Producer and Consumer metrics (the microservice)

A good guide for having a minimal and effective monitoring system is to monitor the Four Golden Signals, recommended by the Google SRE book.

Four Golder Signals: Traffic / Latency /  Errors / Saturation

- **Traffic**
	- `Request and response rates`: For producers, the response rate represents the rate of responses received from brokers. The request rate is the rate at which producers send data to brokers
	- `Records consumed rate`: Allows to discover trends in your data consumption and create a baseline against which you can alert.
	- `Fetch rate`: The fetch rate of a consumer can be a good indicator of overall consumer health.
	- `Outgoing byte rate`, `I/O wait time`, etc
- **Latency:**
	- `Request latency average`: The average request latency is a measure of the amount of time between when KafkaProducer.produce(...) was called until the producer receives a response from the broker.
- **Errors**:
	- `Failure rate`: Failures in python code exection and connectivy errors
- **Saturation:**
	- `Container resources usage`:  including memory assigned, CPU usage and persistence volumes.

### Zookeeper metrics
- `Number of alive connections`: ZooKeeper reports the number of clients connected to it via the num_alive_connections metric. This represents all connections, including connections to non-ZooKeeper nodes.
- `Average latency`: The average request latency is the average time it takes (in milliseconds) for ZooKeeper to respond to a request. ZooKeeper will not respond to a request until it has written the transaction to its transaction log.
