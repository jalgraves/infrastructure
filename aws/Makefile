export SELF ?= $(MAKE)

SHELL := /bin/bash
.SHELLFLAGS += -e
.ONESHELL:

upgrade ?= false
region_code ?= use2
aws_workspace ?= $(env)-aws-$(directory)-$(region_code)
org ?= jalgraves

## Run terraform init on aws directory
aws/init:
	cd aws/$(directory) && \
		terraform init -upgrade=$(upgrade)

## Run terraform plan on aws directory
aws/plan: aws/workspace
	cd aws/$(directory) && \
		aws-vault exec beantown:dev -- terraform plan -var-file="${HOME}/tfvars/$(org)/$(directory).tfvars"

## Run terraform plan on specific resource in aws an directory
aws/plan/target: aws/workspace
	cd aws/$(directory) && \
		aws-vault exec beantown:dev -- terraform plan -var-file="${HOME}/tfvars/$(org)/$(directory).tfvars" -target=$(target)

## Run terraform apply on aws directory
aws/apply: aws/workspace
	cd aws/$(directory) && \
		aws-vault exec beantown:dev -- terraform apply -var-file="${HOME}/tfvars/$(org)/$(directory).tfvars"

## Run terraform apply on specific resource in an aws directory
aws/apply/target: aws/workspace
	cd aws/$(directory) && \
		aws-vault exec beantown:dev -- terraform apply -var-file="${HOME}/tfvars/$(org)/$(directory).tfvars" -target=$(target)

## Run terraform destroy on aws directory
aws/destroy: aws/workspace
	cd aws/$(directory) && \
		aws-vault exec beantown:dev -- terraform destroy -var-file="${HOME}/tfvars/$(org)/$(directory).tfvars"

## Run terraform destroy on specific resource in an aws directory
aws/destroy/target: aws/workspace
	cd aws/$(directory) && \
		aws-vault exec beantown:dev -- terraform destroy -var-file="${HOME}/tfvars/$(org)/$(directory).tfvars" -target=$(target)

## Run terraform taint on specific resource in an aws directory
aws/taint: aws/workspace
	cd aws/$(directory) && \
		aws-vault exec beantown:dev -- terraform taint $(target)

## Run terraform destroy on aws directory
aws/validate: aws/workspace
	cd aws/$(directory) && terraform validate

## Run terraform workspace select
aws/workspace:
	cd aws/$(directory) && \
		terraform workspace select $(aws_workspace)

## Run terraform workspace list
aws/workspace/list: aws/init
	cd aws/$(directory) && \
		terraform workspace list

## Run terraform providers lock on aws directory
aws/lock: aws/init
	cd aws/$(directory) && \
		terraform providers lock -platform=darwin_amd64 -platform=linux_amd64

## List resources in terraform state. Example: make aws/state/list directory=eks env=load
aws/state/list: aws/workspace
	cd aws/$(directory) && \
		terraform state list
