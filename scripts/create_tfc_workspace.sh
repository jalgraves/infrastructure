#!/bin/bash

HELP="""
Create TFC (Terraform Cloud) CLI-driven workspaces

These workspaces are used for creating Terraform Cloud VCS-driven workspaces
which are responsible for running Terraform commands based on events triggered
in GitHub repos

Refs:
- https://developer.hashicorp.com/terraform/cloud-docs/run/cli
- https://developer.hashicorp.com/terraform/cloud-docs/run/ui

Args:
-h | --help       Print this message and exit
-n | --name       The full name of the workspace being created
-p | --provider   The primary Terraform provider resources are being created for (Used for tagging)
-r | --repository The name of the repository that the VCS-driven workspace will be tracking

"""

ARGS=("$@")
ARG_INDEX=0
for arg in "${ARGS[@]}"; do
  value=$((ARG_INDEX+1))
  case $arg in
    -h|--help)
      echo "${HELP}"
      exit 0
      ;;
    -n|--name)
        NAME="${ARGS[$value]}"
    ;;
    -p|--provider)
        PROVIDER="${ARGS[$value]}"
    ;;
    -r|--repository)
      REPOSITORY="${ARGS[$value]}"
    ;;
  esac
  ((ARG_INDEX=ARG_INDEX+1))
done

if test -z "${TFC_ORG_TOKEN}"; then
  # Terraform Cloud API token is required
  echo "TFC_ORG_TOKEN env variable not set"
  exit 1
fi

WORKSPACE_DATA=$(curl --request POST \
  --url https://app.terraform.io/api/v2/organizations/jalgraves/workspaces \
  --header "authorization: Bearer ${TFC_ORG_TOKEN}" \
  --header "content-type: application/vnd.api+json" \
  --data "{\"data\": {\"attributes\": {\"name\": \"${NAME}\",\"execution-mode\": \"local\",\"source-name\": \"${REPOSITORY}\"}}}" | jq .)

echo "${WORKSPACE_DATA}"
WORKSPACE_ID=$(echo "${WORKSPACE_DATA}" | jq .data.id | tr -d '"')
WORKSPACE_URL="https://app.terraform.io/api/v2/workspaces/${WORKSPACE_ID}/relationships/tags"
echo "${WORKSPACE_URL}"
sleep 5

curl \
  --header "Authorization: Bearer ${TFC_ORG_TOKEN}" \
  --header "Content-Type: application/vnd.api+json" \
  --request POST \
  --data "{\"data\": [{\"type\": \"tags\", \"attributes\": {\"name\": \"tfc\"}}, {\"type\": \"tags\", \"attributes\": {\"name\": \"${PROVIDER}\"}}]}" \
  "${WORKSPACE_URL}"
