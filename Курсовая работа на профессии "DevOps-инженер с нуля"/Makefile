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
	@echo "Используйте: terraform -chdir=$(TF_DIR) output -json | python3 -c \"...\""
	@echo "Или создайте inventory/hosts.yml вручную на основе terraform output"
	@echo "См. документацию в docs/runbook.md"
	@test -f $(INVENTORY_FILE) || (echo "Ошибка: $(INVENTORY_FILE) не найден. Создайте его вручную." && exit 1)

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
