export MAKE_PATH ?= $(shell pwd)
export SELF ?= $(MAKE)

SHELL := /bin/bash

org ?= beantown

## Build K8s worker AMI
packer/k8s_worker/build:
	cd packer/ && \
	packer init k8s-worker-ami-template.pkr.hcl && \
	aws-vault exec $(org):dev -- packer build k8s-worker-ami-template.pkr.hcl
