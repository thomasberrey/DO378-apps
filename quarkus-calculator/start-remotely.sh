#!/bin/bash

oc new-project calculator
oc project calculator
oc delete all --all

oc delete -f jaeger-resource.yml
oc apply -f jaeger-resource.yml

oc delete -f activemq-resource.yml
oc apply -f activemq-resource.yml

echo "Starting the 'adder' project"
cd adder
mvn clean
mvn package -Dquarkus.container-image.push=true
oc delete -f target/kubernetes/openshift.yml
oc apply -f target/kubernetes/openshift.yml
cd ..

echo "Starting the 'multiplier' project"
cd multiplier
mvn clean
mvn package -Dquarkus.container-image.push=true
oc delete -f target/kubernetes/openshift.yml
oc apply -f target/kubernetes/openshift.yml
cd ..

echo "Starting the 'solver' project"
cd solver
mvn clean
mvn package -Dquarkus.container-image.push=true
oc delete -f target/kubernetes/openshift.yml
oc apply -f target/kubernetes/openshift.yml
cd ..

sleep 30

EQUATION="5*4+3*2+1"
SOLVER_ROUTE=$(oc get route solver -o template --template '{{ "http://" }}{{ .spec.host }}')
RESULT=`(http $SOLVER_ROUTE/solver/$EQUATION/traceId)`
echo "$EQUATION = $RESULT"
