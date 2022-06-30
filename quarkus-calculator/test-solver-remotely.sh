#!/bin/bash

SOLVER_ROUTE=$(oc get route solver -o template --template '{{ "http://" }}{{ .spec.host }}')

echo "Testing solver microservice"

A=1
B=2
C=3
D=4
E=5

while [ true ]
do
  date
  http "http $SOLVER_ROUTE/solver/$A*$B+$C*$D+$E/traceId"
  A=$(( $A + 1 ))
  B=$(( $B + 1 ))
  C=$(( $C + 1 ))
  D=$(( $D + 1 ))
  E=$(( $E + 1 ))
done
