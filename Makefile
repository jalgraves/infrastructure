
-include \
	aws/Makefile \
	tfc/Makefile

export MAKE_PATH ?= $(shell pwd)
export SELF ?= $(MAKE)

TF_VERSION := $(shell grep 'terraform' .tool-versions | awk '{print $$2}')

SHELL := /bin/bash

MAKE_FILES = \
	${MAKE_PATH}/Makefile \
	${MAKE_PATH}/aws/Makefile \
	${MAKE_PATH}/tfc/Makefile

default:: $(DEFAULT_HELP_TARGET)
	@exit 0


asdf:
	asdf plugin add terraform && \
	asdf install terraform $(TF_VERSION) && \
		asdf local terraform $(TF_VERSION)

## Install pre-commit hooks
pre-commit/install:
	pre-commit install --install-hooks --allow-missing-config -t pre-commit -t prepare-commit-msg

## Install Homebrew
brew/install:
	[ ! -f "`which brew`" ] || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"


## Setup project dependencies
setup: brew/install brew/deps asdf pre-commit create_tfvars

## Print terraform version
version:
	@echo $(TF_VERSION)

brew/deps:
	brew tap Homebrew/bundle
	brew bundle

## Show available commands
help:
	@printf "Available targets:\n\n"
	@$(SELF) -s help/generate | grep -E "\w($(HELP_FILTER))"
	@printf "\n"

help/generate:
	@awk '/^[a-zA-Z\_0-9%:\\\/-]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = $$1; \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			gsub("\\\\", "", helpCommand); \
			gsub(":+$$", "", helpCommand); \
			printf "  \x1b[32;01m%-35s\x1b[0m %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKE_FILES) | sort -u
	@printf "\n\n"

create_tfvars:
	mkdir -p ${HOME}/tfvars
	touch ${HOME}/tfvars/tfc.tfvars

## Lint terraform
tf/lint:
	scripts/lint.sh || rm -rf .lint_tmp

## Update terraform version. Example: make tf/update version=1.4.6
tf/update:
	scripts/update_terraform_version.sh --version $(version)

## Format terraform code
fmt:
	terraform fmt --recursive

foo/bar:
	echo $@
	echo $*
