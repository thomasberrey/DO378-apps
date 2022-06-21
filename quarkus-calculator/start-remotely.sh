#!/bin/bash

oc new-project calculator
oc project calculator

echo "Starting the 'adder' project "
cd adder
mvn package -Dquarkus.container-image.push=true
oc delete -f target/kubernetes/openshift.yml
oc apply -f target/kubernetes/openshift.yml
cd ..

echo "Starting the 'multiplier' project "
cd multiplier
mvn package -Dquarkus.container-image.push=true
oc delete -f target/kubernetes/openshift.yml
oc apply -f target/kubernetes/openshift.yml
cd ..

echo "Starting the 'solver' project "
cd solver
mvn package -Dquarkus.container-image.push=true
oc delete -f target/kubernetes/openshift.yml
oc apply -f target/kubernetes/openshift.yml
cd ..

sleep 30

EQUATION="5*4+3"
SOLVER_ROUTE=$(oc get route solver -o template --template '{{ "http://" }}{{ .spec.host }}')
RESULT=`(http $SOLVER_ROUTE/solver/$EQUATION)`
echo "$EQUATION = $RESULT"
