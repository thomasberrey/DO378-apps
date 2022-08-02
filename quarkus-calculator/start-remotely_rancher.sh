#!/bin/bash

NAMESPACE=calculator

kubectl create namespace $NAMESPACE
kubectl config set-context --current --namespace=$NAMESPACE
kubectl delete all --all

helm uninstall jaegertracing
helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
helm install jaegertracing jaegertracing/jaeger

export JAEGER_POD_NAME=$(kubectl get pods --namespace $NAMESPACE -l "app.kubernetes.io/instance=jaegertracing,app.kubernetes.io/component=query" -o jsonpath="{.items[0].metadata.name}")

JAEGER_PODMAN_STATUS=`kubectl get pod $JAEGER_POD_NAME | grep $JAEGER_POD_NAME | awk '{print $3}'`

while [ $JAEGER_PODMAN_STATUS != "Running" ]
do
  JAEGER_PODMAN_STATUS=`kubectl get pod $JAEGER_POD_NAME | grep $JAEGER_POD_NAME | awk '{print $3}'`
  DATE=`date`
  echo "$DATE - JAEGER_PODMAN_STATUS: $JAEGER_PODMAN_STATUS"
  sleep 5
done

kubectl port-forward --namespace $NAMESPACE $JAEGER_POD_NAME 8080:16686 &

helm uninstall nats
helm repo add nats https://nats-io.github.io/k8s/helm/charts/
helm install nats nats/nats --values nats_ha_and_jetstream.yml

#kubectl port-forward -n kube-system $(kubectl -n kube-system get pods --selector "app.kubernetes.io/name=traefik" --output=name) 9000:9000

