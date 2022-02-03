#!/usr/bin/env bash

GKE_CLUSTER=$(cd resources/03-gke && terragrunt output -raw name)
GKE_CLUSTER_TYPE=$(cd resources/03-gke && terragrunt output -raw type)
REGION=$(cd resources/01-common && terragrunt output -raw region)
ZONE=$(cd resources/01-common && terragrunt output -raw zone)

echo GKE_CLUSTER: $GKE_CLUSTER
echo GKE_CLUSTER_TYPE: $GKE_CLUSTER_TYPE
echo ZONE: $ZONE
echo

if [ -z "$GKE_CLUSTER" ]; then
  echo Error cannot find GKE cluster.
  exit 1
fi

if [ "${GKE_CLUSTER_TYPE}" == "regional" ]; then
  gcloud container clusters get-credentials $GKE_CLUSTER --region $REGION
else
  gcloud container clusters get-credentials $GKE_CLUSTER --zone $ZONE
fi

kubectl cluster-info
kubectl get nodes
kubectl get all

echo
