SHELL := /bin/bash

TERRAFORM := terraform
ANSIBLE := ansible-playbook
WAIT := sleep 60
CD_TERRAFORM := cd src/terraform
CD_CLUSTER := cd src/terraform/cluster
CD_STANDALONE := cd src/terraform/standalone


.PHONY: cluster standalone cluster-destroy standalone-destroy benchmark

# MAIN COMMANDS
cluster: create-cluster

cluster-redeploy: cluster-destroy
	@echo "Sleeping for 1 minute for destroy to complete..."
	@sleep 60
	@$(MAKE) create-cluster

cluster-destroy:
	@echo "Destroying MySQL cluster..."
	$(CD_CLUSTER) && \
		$(TERRAFORM) destroy -auto-approve

standalone: create-standalone

standalone-destroy:
	@echo "Destroying standalone MySQL instance..."
	$(CD_STANDALONE) && \
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

output-cluster:
	$(CD_CLUSTER) && \
		$(TERRAFORM) output

# Sub commands
create-cluster:
	@echo "Creating MySQL cluster..."
	$(CD_CLUSTER) && \
		$(TERRAFORM) init && \
		$(TERRAFORM) plan && \
		$(TERRAFORM) apply -auto-approve
	@echo "Sleeping for 1 minute for boot to complete..."
	@$(WAIT)
	@$(MAKE) configure-cluster


configure-cluster:
	@echo "Configuring MySQL cluster with ansible..."
	@export ANSIBLE_HOST_KEY_CHECKING=False
	@$(MAKE) configure-cluster-manager
	@for task in configure-cluster-worker configure-cluster-proxy configure-cluster-trusted_host configure-cluster-gatekeeper; do \
		(export ANSIBLE_HOST_KEY_CHECKING=False && $(MAKE) $$task) & \
	done; \
	wait


configure-cluster-manager:
	@echo "Configuring manager MySQL instance with ansible..."
	$(CD_CLUSTER) && \
		$(ANSIBLE) -i ./ansible/inventory.ini ./ansible/playbooks/manager-playbook.yaml

configure-cluster-worker:
	@echo "Configuring workers MySQL instance with ansible..."
	$(CD_CLUSTER) && \
		$(ANSIBLE) -i ./ansible/inventory.ini ./ansible/playbooks/worker-playbook.yaml

configure-cluster-proxy:
	@echo "Configuring proxy instance with ansible..."
	$(CD_CLUSTER) && \
		$(ANSIBLE) -i ./ansible/inventory.ini ./ansible/playbooks/proxy-playbook.yaml

configure-cluster-trusted_host:
	@echo "Configuring trusted host instance with ansible..."
	$(CD_CLUSTER) && \
		$(ANSIBLE) -i ./ansible/inventory.ini ./ansible/playbooks/trusted_host-playbook.yaml

configure-cluster-gatekeeper:
	@echo "Configuring gatekeeper instance with ansible..."
	$(CD_CLUSTER) && \
		$(ANSIBLE) -i ./ansible/inventory.ini ./ansible/playbooks/gatekeeper-playbook.yaml

create-standalone:
	@echo "Creating standalone MySQL instance..."
	$(CD_STANDALONE) && \
		$(TERRAFORM) init && \
		$(TERRAFORM) plan && \
		$(TERRAFORM) apply -auto-approve
	@echo "Sleeping for 1 minute for boot to complete..."
	@$(WAIT)
	@$(MAKE) configure-standalone


configure-standalone:
	@echo "Configuring MySQL instance with ansible..."
	$(CD_STANDALONE) && \
		$(ANSIBLE) -i ./ansible/inventory.ini ./ansible/playbooks/playbook.yaml

release:
	zip -r release_2013658.zip src Makefile report/project.pdf requirements.txt

# Helper functions

define run-benchmark
	@echo "Running benchmark on $1..."
	$(CD_TERRAFORM) && \
	cd ./$1 && \
		$(ANSIBLE) -i ./ansible/inventory.ini ./ansible/playbooks/benchmark-playbook.yaml
endef

define plan
	$(CD_TERRAFORM) && \
	cd ./$1 && \
		$(TERRAFORM) init && \
		$(TERRAFORM) plan
endef

define apply
	$(CD_TERRAFORM) && \
	cd ./$1 && \
		$(TERRAFORM) apply
endef
