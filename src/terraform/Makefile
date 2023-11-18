SHELL := /bin/bash

.PHONY: cluster standalone cluster-destroy standalone-destroy

cluster:
	@echo "Creating MySQL cluster..."
	@cd ./cluster && \
		terraform init && \
		terraform plan && \
		terraform apply -auto-approve
	@echo "Configuring workers MySQL instance with ansible..."
	@cd ./cluster && \
		ansible-playbook -i ./ansible/inventory.ini ./ansible/playbooks/worker-playbook.yaml
	@echo "Configuring manager MySQL instance with ansible..."
	@cd ./cluster && \
		ansible-playbook -i ./ansible/inventory.ini ./ansible/playbooks/manager-playbook.yaml

cluster-proxy:
	@echo "Creating MySQL cluster..."
	@cd ./cluster && \
		terraform init && \
		terraform plan && \
		terraform apply -auto-approve
	@echo "Configuring proxy instance with ansible..."
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

