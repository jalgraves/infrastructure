#!/bin/bash

HELP="""
Delete the Tailscale subnet router running in a VPC. This can be ran after creating new
Tailscale auth keys. Once the subnet router is deleted, rerun the terraform for the vpc workspace

Args:
-h | --help           Print this message and exit
-e | --env            The environment to run the command in
-r | --region-code    The region code of the AWS region to run the command in

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
    -e|--env)
      ENV="${ARGS[$value]}"
      ;;
    -r|--region-code)
      REGION_CODE="${ARGS[$value]}"
      ;;
  esac
  ((ARG_INDEX=ARG_INDEX+1))
done

if [[ "${REGION_CODE}" = "use1" ]]; then
  REGION=us-east-1
elif [[ "${REGION_CODE}" = "euc1" ]]; then
  REGION=eu-central-1
fi

INSTANCE=$(aws-vault exec "${ENV}:admin" -- aws ec2 describe-instances \
  --region "${REGION}" --filters "Name=tag:Name,Values=${ENV}-${REGION_CODE}-tailscale-subnet-router" | \
  jq .Reservations[].Instances[].InstanceId | tr -d '"')

aws-vault exec "${ENV}:admin" -- aws ec2 terminate-instances --region "${REGION}" --instance-ids "${INSTANCE}" | jq .
