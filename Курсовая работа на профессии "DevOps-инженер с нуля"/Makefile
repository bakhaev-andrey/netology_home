SHELL := /bin/bash
TF_DIR := terraform
ANSIBLE_DIR := ansible
INVENTORY_FILE := inventory/hosts.yml

.PHONY: bootstrap fmt tf-init tf-plan tf-apply tf-destroy tf-validate ansible-ping ansible-site render-inventory verify

bootstrap:
	python3 -m venv .venv
	. .venv/bin/activate && pip install --upgrade pip && pip install -r requirements.txt

fmt:
	terraform -chdir=$(TF_DIR) fmt -recursive

tf-init:
	terraform -chdir=$(TF_DIR) init

tf-plan:
	terraform -chdir=$(TF_DIR) plan -out=$(TF_DIR)/tfplan

tf-apply:
	terraform -chdir=$(TF_DIR) apply -auto-approve

tf-destroy:
	terraform -chdir=$(TF_DIR) destroy -auto-approve

tf-validate:
	terraform -chdir=$(TF_DIR) validate

render-inventory:
	@echo "Генерация inventory из Terraform outputs..."
	@terraform -chdir=$(TF_DIR) output -json > /tmp/tf_output.json
	@python3 -c "import json, yaml, sys; data = json.load(open('/tmp/tf_output.json')); ssh_user = data.get('ssh_user', {}).get('value', 'ubuntu'); bastion_ip = data.get('bastion_public_ip', {}).get('value'); proxy_cmd = f\"-o ProxyCommand='ssh -W %h:%p -q {ssh_user}@{bastion_ip}' -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null\"; inv = {'all': {'children': {'bastion': {'hosts': {'bastion': {'ansible_host': bastion_ip}}}, 'web': {'hosts': {k: {'ansible_host': v.get('value')} for k, v in data.get('web_private_ips', {}).get('value', {}).items()}, 'vars': {'ansible_ssh_common_args': proxy_cmd}}, 'monitoring': {'hosts': {'prometheus': {'ansible_host': data.get('prometheus_private_ip', {}).get('value')}, 'grafana': {'ansible_host': data.get('grafana_public_ip', {}).get('value')}}, 'vars': {'ansible_ssh_common_args': proxy_cmd}}, 'logging': {'hosts': {'elasticsearch': {'ansible_host': data.get('elasticsearch_private_ip', {}).get('value')}, 'kibana': {'ansible_host': data.get('kibana_public_ip', {}).get('value')}}, 'vars': {'ansible_ssh_common_args': proxy_cmd}}}}}; yaml.dump(inv, open('$(INVENTORY_FILE)', 'w'), default_flow_style=False, allow_unicode=True)"

ansible-ping: render-inventory
	ANSIBLE_CONFIG=$(ANSIBLE_DIR)/ansible.cfg ansible -i $(INVENTORY_FILE) all -m ping

ansible-site: render-inventory
	ANSIBLE_CONFIG=$(ANSIBLE_DIR)/ansible.cfg ansible-playbook -i $(INVENTORY_FILE) $(ANSIBLE_DIR)/playbooks/site.yml

verify:
	terraform -chdir=$(TF_DIR) fmt -recursive -check
	terraform -chdir=$(TF_DIR) validate
	@if command -v ansible-lint >/dev/null 2>&1; then \
		ANSIBLE_CONFIG=$(ANSIBLE_DIR)/ansible.cfg ansible-lint $(ANSIBLE_DIR)/playbooks/site.yml; \
	else \
		echo "ansible-lint не установлен, пропускаем проверку" >&2; \
	fi
