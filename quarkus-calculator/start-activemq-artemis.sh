#!/bin/bash

echo "Starting Apache ActiveMQ Artemis"
podman machine start
podman stop activemq
podman rm activemq
podman run --name activemq -p 8161:8161 -p 61616:61616 -e ARTEMIS_USERNAME=quarkus -e ARTEMIS_PASSWORD=quarkus vromero/activemq-artemis:latest

# Connect to Apache ActiveMQ Artemis at http://localhost:8161
