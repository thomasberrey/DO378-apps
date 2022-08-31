#!/bin/bash

NAMESPACE=calculator

kubectl create namespace $NAMESPACE
kubectl config set-context --current --namespace=$NAMESPACE
kubectl delete all --all

curl -sL https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v0.21.2/install.sh | bash -s v0.21.2

kubectl create -f https://operatorhub.io/install/jaeger.yaml
kubectl apply -f jaeger-resource.yml

helm uninstall nats
helm repo add nats https://nats-io.github.io/k8s/helm/charts/
helm install nats nats/nats --values nats_ha_and_jetstream.yml

helm uninstall nginx
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install nginx bitnami/nginx
kubectl apply -f nginx_ingress.yml

kubectl create -f https://operatorhub.io/install/rabbitmq-cluster-operator.yaml
kubectl apply -f rabbitmq-resource.yml

kubectl apply -k "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.4.0"
helm uninstall traefik
helm repo add traefik https://helm.traefik.io/traefik
helm install traefik --set experimental.kubernetesGateway.enabled=true traefik/traefik

kubectl apply -f adder_kubernetes.yml
kubectl apply -f multiplier_kubernetes.yml
kubectl apply -f solver_kubernetes.yml
