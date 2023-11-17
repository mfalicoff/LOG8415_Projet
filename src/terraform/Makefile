.PHONY: all init plan apply destroy ansible

all: init plan apply ansible

init:
	cd standalone && \
	terraform init

plan:
	cd standalone && \
	terraform plan

apply:
	cd standalone && \
	terraform apply -auto-approve

destroy:
	cd standalone && \
	terraform destroy -auto-approve

ansible:
	cd standalone/ansible && \
	ansible-playbook playbook.yaml
