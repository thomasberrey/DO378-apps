#!/bin/bash

echo "Starting NATS Server"
docker rm nats
docker run --name nats -p 4222:4222 -ti nats:latest
