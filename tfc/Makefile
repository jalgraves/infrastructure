export SELF ?= $(MAKE)

SHELL := /bin/bash
tfc_var_file ?= "${HOME}/tfvars/jalgraves/tfc.tfvars"
.SHELLFLAGS += -e
.ONESHELL:

upgrade ?= false
workspace ?= $(@F)-tfc
provider ?= $(@F)
extra_args ?= ""

## Run terraform init on tfc provider directory. Run with upgrade=true to add -upgrade=true flag. Example: make tfc/init provider=aws upgrade=true
tfc/init/%:
	cd tfc/$(@F) && \
		terraform init -upgrade=$(upgrade)

## Run terraform plan on tfc provider directory. Example: make tfc/plan provider=aws
tfc/plan/%:
	cd tfc/$(@F) && \
		terraform workspace select $(workspace) && \
		terraform plan -var-file=$(tfc_var_file)

## Run terraform apply on tfc provider directory. Example: make tfc/apply provider=aws
tfc/apply/%:
	cd tfc/$(provider) && \
		terraform workspace select $(workspace) && \
		terraform apply -var-file=$(tfc_var_file) $(extra_args)

## Run terraform destroy on tfc provider directory. Example: make tfc/destroy provider=aws
tfc/destroy/%:
	cd tfc/$(provider) && \
		terraform destroy -var-file=$(tfc_var_file)

## Run terraform validate on tfc provider directory. Example: make tfc/validate provider=aws
tfc/validate/%:
	cd tfc/$(@F) && \
		terraform workspace select $(workspace) && \
		terraform validate

## Run terraform workspace select
tfc/workspace:
	cd tfc/$(provider) && \
		terraform workspace select $(workspace)

## Run terraform workspace list
tfc/workspace/list/%:
	cd tfc/$(@F) && \
		terraform init -upgrade=$(upgrade) && \
		terraform workspace list

## Create CLI-driven terraform workspace. Example: make tfc/workspace/create name=development-okta-tfc provider=okta repo=infrastructure
tfc/workspace/create:
	./scripts/create_tfc_workspace.sh --name $(name) --provider $(provider) --repository $(repo)

## Run terraform providers lock on tfc provider directory. Example: make tfc/lock provider=aws upgrade=true
tfc/lock/%:
	cd tfc/$(@F) && \
		terraform init -upgrade=$(upgrade) && \
		terraform providers lock -platform=darwin_amd64 -platform=linux_amd64
