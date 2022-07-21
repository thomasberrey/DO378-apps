#!/bin/bash

echo "Starting NATS Server"
podman machine start
podman stop nats
podman rm nats
podman run --name nats -p 4222:4222 -p 8222:8222 nats:latest -js --http_port 8222
