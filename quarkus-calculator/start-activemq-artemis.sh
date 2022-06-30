#!/bin/bash

echo "Starting the Apache ActiveMQ Artemis "
docker run -it --rm -p 8161:8161 -p 61616:61616 -e ARTEMIS_USERNAME=quarkus -e ARTEMIS_PASSWORD=quarkus vromero/activemq-artemis:2.9.0-alpine
