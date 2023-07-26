#!/bin/bash

CLUSTER="${1}"
ENV=$(echo "${CLUSTER}" | cut -f 1 -d'-')

K8S_VERSION=$(aws-vault exec "${ENV}":ro -- aws eks describe-cluster \
  --name "${CLUSTER}" \
  --region us-east-1 | jq '.cluster["version"]' | tr -d '"')

LATEST_K8S_VERSION=$(aws-vault exec "${ENV}":ro -- aws eks describe-addon-versions | jq -r ".addons[] | .addonVersions[] | .compatibilities[] | .clusterVersion" | sort -r | head -n 1)

printf "\n%s\n%s\n\n" \
  "${CLUSTER} is currently running Kubernetes version ${K8S_VERSION}" \
  "The latest available Kubernetes version is ${LATEST_K8S_VERSION}"
