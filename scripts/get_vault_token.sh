#!/bin/bash
#
# Retrieve a temporary Vault token for an automated user
#

set -euo pipefail
# -e  Exit immediately if a command exits with a non-zero status
# -o pipefail  The return value of a pipeline is the status of
#              the last command to exit with a non-zero status

STDIN=$(cat)  # Passed from Terraform external data source
ADDRESS=$(echo "${STDIN}" | tr ',' '\n' | grep 'address' | cut -f 2 -d ' ' | cut -f 2,3,4 -d ':' |tr -d '\"')  # URL of Vault server
NAMESPACE=$(echo "${STDIN}" | grep -Eo '"namespace"[^,]*' | grep -Eo '[^:]*$' | tr -d ' "')  # Vault namespace
ROLE_ID=$(echo "${STDIN}" | grep -Eo '"role_id"[^,]*' | grep -Eo '[^:]*$' | tr -d ' "')
SECRET_ID=$(echo "${STDIN}" | grep -Eo '"secret_id"[^,]*' | grep -Eo '[^:]*$' | tr -d ' "}')

VAULT_TOKEN=$(curl \
  -s \
  -v \
  --request POST \
  --data "{\"role_id\": \"${ROLE_ID}\", \"secret_id\": \"${SECRET_ID}\"}" \
  -H "X-Vault-Namespace: ${NAMESPACE}" \
  "${ADDRESS}/v1/auth/approle/login" | tr ',' '\n' | grep 'auth' | cut -f 6 -d '"')

echo "${VAULT_TOKEN}" > "${HOME}/vault_response_debug.txt"

# Output must bee valid JSON, strings only
printf "{\"token\": \"%s\"}" "${VAULT_TOKEN}"
