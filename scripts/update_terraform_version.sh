#!/bin/bash

HELP="""
Update the version of Terraform used locally, in circleci, and
TFC (Terraform Cloud)

Args:
-h | --help       Print this message and exit
-v | --version    The version of Terraform to update to

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
    -v|--version)
      VERSION="${ARGS[$value]}"
    ;;
  esac
  ((ARG_INDEX=ARG_INDEX+1))
done

CURRENT_TERRAFORM_VERSION=$(grep 'terraform' .tool-versions | awk '{print $2}' )
echo "Updating Terraform from ${CURRENT_TERRAFORM_VERSION} to ${VERSION}"

sed -i -e "s/${CURRENT_TERRAFORM_VERSION}/${VERSION}/g" .circleci/*.yml
rm -rf .circleci/*-e

sed -i -e "s/${CURRENT_TERRAFORM_VERSION}/${VERSION}/g" tfc/**/*.tf
rm -rf tfc/**/*-e

asdf install terraform "${VERSION}"
asdf local terraform "${VERSION}"
