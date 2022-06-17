#!/bin/bash

oc new-project calculator
oc project calculator

echo "Starting the 'solver' project "
cd solver
mvn package -Dquarkus.container-image.push=true
oc apply -f target/kubernetes/openshift.yml
cd ..

echo "Starting the 'adder' project "
cd adder
mvn package -Dquarkus.container-image.push=true
oc apply -f target/kubernetes/openshift.yml
cd ..

echo "Starting the 'multiplier' project "
cd multiplier
mvn package -Dquarkus.container-image.push=true
oc apply -f target/kubernetes/openshift.yml
cd ..

EQUATION="5"
SOLVER_URL=`(oc get routes/solver | grep "^solver" | awk '{print $2}')`
RESULT=`(http http://$SOLVER_URL/solver/$EQUATION)`
echo "$EQUATION = $RESULT"
