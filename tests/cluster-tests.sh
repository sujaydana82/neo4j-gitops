#!/bin/bash

NS=neo4j

echo "=== Checking cluster pods ==="
kubectl get pods -n $NS

echo "=== Checking cluster overview ==="
kubectl exec -n $NS neo4j-core-0 -- cypher-shell "CALL dbms.cluster.overview()"

echo "=== Creating test data ==="
kubectl exec -n $NS neo4j-core-0 -- cypher-shell \
"UNWIND range(1,50) AS id CREATE (:Test {id:id})"

echo "=== Checking data on all cores ==="
for i in 0 1 2; do
  kubectl exec -n $NS neo4j-core-$i -- cypher-shell \
  "MATCH (n:Test) RETURN count(n)"
done

echo "=== Testing leader election ==="
LEADER=$(kubectl exec -n $NS neo4j-core-0 -- cypher-shell \
"CALL dbms.cluster.overview() YIELD role,serverId RETURN serverId WHERE role='LEADER'")

echo "Leader is: $LEADER"
TARGET=$(echo $LEADER | tr -d '\r')

echo "Deleting leader pod: $TARGET"
kubectl delete pod $TARGET -n $NS

sleep 15

echo "=== New cluster overview ==="
kubectl exec -n $NS neo4j-core-0 -- cypher-shell "CALL dbms.cluster.overview()"

echo "=== PVC persistence test ==="
kubectl exec -n $NS neo4j-core-0 -- cypher-shell \
"MATCH (n:Test) RETURN count(n)"
