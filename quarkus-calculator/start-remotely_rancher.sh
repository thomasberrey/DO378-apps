#!/bin/bash

kubectl create namespace calculator
kubectl config set-context --current --namespace=calculator
kubectl delete all --all

helm uninstall nats
helm repo add nats https://nats-io.github.io/k8s/helm/charts/
helm install nats nats/nats --values nats_ha_and_jetstream.yml




#kubectl port-forward -n kube-system $(kubectl -n kube-system get pods --selector "app.kubernetes.io/name=traefik" --output=name) 9000:9000

#oc delete -f jaeger-resource.yml
#oc apply -f jaeger-resource.yml

#oc delete -f activemq-resource.yml
#oc apply -f activemq-resource.yml

#echo "Starting the 'adder' project"
#cd adder
#mvn clean
#mvn package -Dquarkus.container-image.push=true
#oc delete -f target/kubernetes/openshift.yml
#oc apply -f target/kubernetes/openshift.yml
#cd ..

#echo "Starting the 'multiplier' project"
#cd multiplier
#mvn clean
#mvn package -Dquarkus.container-image.push=true
#oc delete -f target/kubernetes/openshift.yml
#oc apply -f target/kubernetes/openshift.yml
#cd ..

#echo "Starting the 'solver' project"
#cd solver
#mvn clean
#mvn package -Dquarkus.container-image.push=true
#oc delete -f target/kubernetes/openshift.yml
#oc apply -f target/kubernetes/openshift.yml
#cd ..
