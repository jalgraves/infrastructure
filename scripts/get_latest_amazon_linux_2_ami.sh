#!/bin/bash

AWS_REGION="us-east-1"  # Replace with your desired AWS region

LATEST_AMI_ID=$(aws-vault exec "${1}:dev" -- aws ec2 describe-images \
  --region $AWS_REGION \
  --filters "Name=name,Values=amzn2-ami-hvm-2.0.*-x86_64-gp2" "Name=state,Values=available" \
  --query "Images | sort_by(@, &CreationDate) | [-1].ImageId" \
  --output text
)

echo "Latest Amazon Linux 2 AMI ID: ${LATEST_AMI_ID}"
# echo "export PACKER_VAR_source_ami_id=${LATEST_AMI_ID}" > packer_variables.sh
