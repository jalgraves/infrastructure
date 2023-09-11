#!/bin/bash

ARGS=("$@")
ARG_INDEX=0
for arg in "${ARGS[@]}"; do
  value=$((ARG_INDEX+1))
  case $arg in
    --region)
      REGION="${ARGS[$value]}"
      ;;
    --secret_id)
      SECRET_ID="${ARGS[$value]}"
      ;;
    --secret_string)
      SECRET_STRING="${ARGS[$value]}"
      ;;
  esac
  ((ARG_INDEX=ARG_INDEX+1))
done

aws secretsmanager update-secret \
  --region "$REGION" \
  --secret-id "$SECRET_ID" \
  --secret-string "$SECRET_STRING"
