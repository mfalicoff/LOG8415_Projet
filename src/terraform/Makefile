SHELL := /bin/bash

.PHONY: cluster standalone cluster-destroy standalone-destroy benchmark

cluster:
	@echo "Creating MySQL cluster..."
	@cd ./cluster && \
		terraform init && \
		terraform plan && \
		terraform apply -auto-approve
	@echo "Sleeping for 1 minute for bootstrap to complete..."
	@sleep 60
	@echo "Configuring manager MySQL instance with ansible..."
	@cd ./cluster && \
		ansible-playbook -i ./ansible/inventory.ini ./ansible/playbooks/manager-playbook.yaml
	@echo "Configuring workers MySQL instance with ansible..."
	@cd ./cluster && \
		ansible-playbook -i ./ansible/inventory.ini ./ansible/playbooks/worker-playbook.yaml
	@echo "Configuring proxy instance with ansible..."
	@echo "Temporary setup for python proxy..."
	@cd ../apps/proxy && \
		pip freeze > requirements.txt
		ansible-playbook -i ./ansible/inventory.ini ./ansible/playbooks/proxy-playbook.yaml
	@cd ./cluster && \
		ansible-playbook -i ./ansible/inventory.ini ./ansible/playbooks/proxy-playbook.yaml

cluster-proxy:
	@echo "Creating MySQL cluster..."
	@cd ./cluster && \
		terraform init && \
		terraform plan && \
		terraform apply -auto-approve
	@echo "Configuring proxy instance with ansible..."
	@echo "Temporary setup for python proxy..."
	@cd ../apps/proxy && \
		pip freeze > requirements.txt
	@cd ./cluster && \
		ansible-playbook -i ./ansible/inventory.ini ./ansible/playbooks/proxy-playbook.yaml

cluster-destroy:
	@echo "Destroying MySQL cluster..."
	@cd ./cluster && \
		terraform destroy -auto-approve

standalone:
	@echo "Creating standalone MySQL instance..."
	@cd ./standalone && \
		terraform init && \
		terraform plan && \
		terraform apply -auto-approve
	@echo "Configuring MySQL instance with ansible..."
	@cd ./standalone && \
		ansible-playbook -i ./ansible/inventory.ini ./ansible/playbooks/playbook.yaml

standalone-destroy:
	@echo "Destroying standalone MySQL instance..."
	@cd ./standalone && \
		terraform destroy -auto-approve

benchmark:
	standalone
	@echo "Running benchmark on standalone..."
		@cd ./standalone && \
		ansible-playbook -i ./ansible/inventory.ini ./ansible/playbooks/benchmark-playbook.yaml
	cluster
	@echo "Running benchmark on cluster..."
		@cd ./cluster && \
		ansible-playbook -i ./ansible/inventory.ini ./ansible/playbooks/benchmark-playbook.yaml



