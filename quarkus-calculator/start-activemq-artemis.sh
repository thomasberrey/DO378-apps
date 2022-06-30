#!/bin/bash

echo "Starting Apache ActiveMQ Artemis"
docker rm activemq
docker run --name activemq -p 8161:8161 -p 61616:61616 -e ARTEMIS_USERNAME=quarkus -e ARTEMIS_PASSWORD=quarkus vromero/activemq-artemis:latest
