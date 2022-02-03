# terragrunt-gcp-gke-public

## Overview
This example deploys an opinionated GKE cluster with private node pool and public control plane.

![architecture](docs/architecture.png)

The following resources are deployed:

- Cloud NAT
- Cloud Router
- Google Cloud Storage
- GKE Cluster
- VPC

Preemptible VMs are deployed to reduce costs.

The Terraform IaC leverages the Google Terraform registry modules and uses Terragrunt to orchestrate the deployment.

## Pre-Requisites
### Development Environment
Google Cloud Shell is the preferred development environment for deploying this example.

The following tools are required:
- Bash Shell
- Google Cloud SDK v3.30.0+
- Jq
- Kubectl
- Terraform v1.1.0+
- Terragrunt v0.30.0+
- TFsec

All the tools above a pre-installed with Google Cloud Shell, except Terraform, Terragrunt and TFsec.

### IAM
A GCP project with the following permissions are required:

- roles/container.admin
- roles/compute.admin
- roles/iam.serviceAccountAdmin
- roles/iam.serviceAccountUser
- roles/iap.tunnelResourceAccessor 
- roles/resourcemanager.projectIamAdmin
- roles/serviceusage.serviceUsageAdmin
- roles/storage.admin

In order to run the deployment, Google authentication needs to be setup unless using Google Cloud Shell.

If a service account is being used, set the environment `GOOGLE_APPLICATION_CREDENTIALS` as follows:
```bash
export GOOGLE_APPLICATION_CREDENTIALS=/path-to-credentials.json
gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
````

If a user account is being used, execute the following:
```bash
gcloud auth login
gcloud auth application-default login
````

## Setup
Create the file resources/common_vars.json as follows:
```json
{
  "project_id": "_project_",
  "region": "_region_"
}
```
### Optional Local Setup 
The command `sudo make setup` will download and install terraform, terragrunt and tfsec.

### Optional Docker / Podman Setup
A container image containing all the tools pre-installed for local development can be created by cloning the repository https://github.com/nhsy/gcp-devops.

Please ensure either Docker or Podman is pre-installed and execute one of the following to build the container locally.

For docker:
```bash
git clone https://github.com/nhsy/gcp-devops.git
cd gcp-devops
make build
```
For podman:
```bash
git clone https://github.com/nhsy/gcp-devops.git
cd gcp-devops
make podman-build
```

To launch the container image and bind mount the current directory execute the following from the root directory of this repository.

For docker:
```bash
./scripts/docker-start.sh
```
For podman:
```bash
./scripts/podman-start.sh
```

## Usage
### Deployment
Setup the environment variables:
```bash
source ./scripts/env.sh
```

For a quick deployment execute:
```bash

make all
```

For a step by step deployment execute to troubleshoot any errors:
```bash
make init
make validate
make plan
make apply
make cluster
```

### Destroy
To delete everything created execute:
```bash
make destroy
```

### Customisations
The common_vars.json file can be customised as follows:
```json
{
  "project_id": "_project_",
  "region": "europe-west1",

  "preemptible": "true",
 
  "gke_nodes_min": 3,
  "gke_nodes_max": 6,
  "gke_regional": false
}
```
