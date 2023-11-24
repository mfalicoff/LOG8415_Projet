SHELL := /bin/bash

TERRAFORM := terraform
ANSIBLE := ansible-playbook
WAIT := sleep 60

.PHONY: cluster standalone cluster-destroy standalone-destroy benchmark

# MAIN COMMANDS
cluster: create-cluster

cluster-redeploy: cluster-destroy
	@echo "Sleeping for 1 minute for destroy to complete..."
	@sleep 60
	@$(MAKE) create-cluster

cluster-destroy:
	@echo "Destroying MySQL cluster..."
	@cd ./cluster && \
		$(TERRAFORM) destroy -auto-approve

standalone: create-standalone

standalone-destroy:
	@echo "Destroying standalone MySQL instance..."
	@cd ./standalone && \
		$(TERRAFORM) destroy -auto-approve

standalone-redeploy:
	@(MAKE) standalone-destroy
	@echo "Sleeping for 1 minute for destroy to complete..."
	@(MAKE) create-standalone

benchmark:
	$(MAKE) standalone
	$(call run-benchmark,standalone)
	$(MAKE) standalone-destroy
	$(MAKE) create-cluster
	$(call run-benchmark,cluster)
	$(MAKE) cluster-destroy

plan-cluster:
	$(call plan,cluster)

plan-standalone:
	$(call plan,standalone)

apply-cluster:
	$(call apply,cluster)

apply-standalone:
	$(call apply,standalone)

# Sub commands
create-cluster:
	@echo "Creating MySQL cluster..."
	@cd ./cluster && \
		$(TERRAFORM) init && \
		$(TERRAFORM) plan && \
		$(TERRAFORM) apply -auto-approve
	@echo "Sleeping for 1 minute for boot to complete..."
	@$(WAIT)
	@$(MAKE) configure-cluster


configure-cluster:
	@echo "Configuring MySQL cluster with ansible..."
	@$(MAKE) configure-cluster-manager
	@$(MAKE) configure-cluster-worker
	@$(MAKE) configure-cluster-proxy
	@$(MAKE) configure-cluster-trusted_host

configure-cluster-manager:
	@echo "Configuring manager MySQL instance with ansible..."
	@cd ./cluster && \
		$(ANSIBLE) -i ./ansible/inventory.ini ./ansible/playbooks/manager-playbook.yaml

configure-cluster-worker:
	@echo "Configuring workers MySQL instance with ansible..."
	@cd ./cluster && \
		$(ANSIBLE) -i ./ansible/inventory.ini ./ansible/playbooks/worker-playbook.yaml

configure-cluster-proxy:
	@echo "Configuring proxy instance with ansible..."
	@cd ../apps/proxy && \
		pip freeze > requirements.txt
	@cd ./cluster && \
		$(ANSIBLE) -i ./ansible/inventory.ini ./ansible/playbooks/proxy-playbook.yaml

configure-cluster-trusted_host:
	@echo "Configuring trusted host instance with ansible..."
	@cd ../apps/trusted_host && \
		pip freeze > requirements.txt
	@cd ./cluster && \
		$(ANSIBLE) -i ./ansible/inventory.ini ./ansible/playbooks/trusted_host-playbook.yaml

create-standalone:
	@echo "Creating standalone MySQL instance..."
	@cd ./standalone && \
		$(TERRAFORM) init && \
		$(TERRAFORM) plan && \
		$(TERRAFORM) apply -auto-approve
	@echo "Sleeping for 1 minute for boot to complete..."
	@$(WAIT)
	@$(MAKE) configure-standalone


configure-standalone:
	@echo "Configuring MySQL instance with ansible..."
	@cd ./standalone && \
		$(ANSIBLE) -i ./ansible/inventory.ini ./ansible/playbooks/playbook.yaml

# Helper functions

define run-benchmark
	@echo "Running benchmark on $1..."
	@cd ./$1 && \
		$(ANSIBLE) -i ./ansible/inventory.ini ./ansible/playbooks/benchmark-playbook.yaml
endef

define plan
	@cd ./$1 && \
		$(TERRAFORM) init && \
		$(TERRAFORM) plan
endef

define apply
	@cd ./$1 && \
		$(TERRAFORM) apply
endef
