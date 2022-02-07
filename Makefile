#SHELL := /usr/bin/env bash

define header
	$(info Running >>> $(1)$(END))
endef

.PHONY: lint
lint:
	$(call header,$@)
	@scripts/lint.sh

.PHONY: setup
setup:
	$(call header,$@)
	@scripts/setup.sh

.PHONY: pre-reqs
pre-reqs:
	$(call header,$@)
	@scripts/pre-reqs.sh

.PHONY: init
init:
	$(call header,$@)
	@scripts/backend.sh init
	@scripts/tg-wrapper.sh init

.PHONY: validate
validate:
	$(call header,$@)
	@scripts/tg-wrapper.sh validate
	@scripts/tg-wrapper.sh validate-inputs

.PHONY: refresh
refresh:
	$(call header,$@)
	@scripts/tg-wrapper.sh refresh

.PHONY: plan
plan:
	$(call header,$@)
	@scripts/tg-wrapper.sh plan

.PHONY: apply
apply:
	$(call header,$@)
	@scripts/tg-wrapper.sh apply

.PHONY: destroy
destroy: init
	$(call header,$@)
	@scripts/tg-wrapper.sh destroy

.PHONY: clean
clean:
	$(call header,$@)
	@scripts/clean.sh

.PHONY: cluster
cluster:
	$(call header,$@)
	@scripts/cluster.sh

.PHONY: config-sync
config-sync:
	$(call header,$@)
	@scripts/config-sync-install.sh

.PHONY: all
all: pre-reqs init validate apply cluster
