#!/bin/bash

oc new-project calculator
oc project calculator
oc delete all --all

oc apply -f jaeger-resource.yml

oc apply -f activemq-resource.yml

helm uninstall nats
helm repo add nats https://nats-io.github.io/k8s/helm/charts/
helm install nats nats/nats --values nats_ha_and_jetstream.yml

echo "Starting the 'adder' project"
cd adder
#mvn clean
#mvn package -Dquarkus.container-image.push=true
oc delete -f target/kubernetes/openshift.yml
oc apply -f target/kubernetes/openshift.yml
cd ..

echo "Starting the 'multiplier' project"
cd multiplier
#mvn clean
#mvn package -Dquarkus.container-image.push=true
oc delete -f target/kubernetes/openshift.yml
oc apply -f target/kubernetes/openshift.yml
cd ..

echo "Starting the 'solver' project"
cd solver
#mvn clean
#mvn package -Dquarkus.container-image.push=true
oc delete -f target/kubernetes/openshift.yml
oc apply -f target/kubernetes/openshift.yml
cd ..
