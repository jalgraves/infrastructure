export MAKE_PATH ?= $(shell pwd)
export SELF ?= $(MAKE)

SHELL := /bin/bash

org ?= beantown

k8s_worker/build:
	aws-vault exec $(org):dev -- packer build k8s-worker-ami-template.pkr.hcl
