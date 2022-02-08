#!/usr/bin/env bash
set -e

GKE_CLUSTER=$(cd resources/03-gke && terragrunt output -raw name)

echo GKE_CLUSTER: $GKE_CLUSTER
echo

if [[ -z "$GKE_CLUSTER" ]]; then
  echo Error cannot find GKE cluster.
  exit 1
fi

# Install flux cli
command -v flux || curl -s https://fluxcd.io/install.sh | sudo bash

flux check --pre
flux install

# Create demo namespace
kubectl create namespace demo || true # ignore errors, if ns already exists

# Configure sync repos
flux create source git podinfo \
  --url=https://github.com/nhsy/podinfo \
  --branch=demo \
  --interval=30s

flux create kustomization podinfo \
  --source=podinfo \
  --path="./kustomize" \
  --prune=true \
  --interval=5m \
  --target-namespace=demo

kubectl get pods -n flux-system
flux get sources git
flux get kustomizations
kubectl -n demo get deployments,services

#flux delete source git podinfo --silent
#flux delete kustomization podinfo --silent
