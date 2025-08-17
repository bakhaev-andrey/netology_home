# Домашнее задание 7-03: Подъём инфраструктуры в Google Cloud — Бахаев Андрей

### Задание 1
Развернуть инфраструктуру: VPC, NAT, бастион (публичный IP), два приватных веб‑сервера (без внешних IP), firewall.

Файлы решения:
- [cloud-init.yml](./cloud-init.yml)
- [terraform/main.tf](./terraform/main.tf)
- [terraform/network.tf](./terraform/network.tf)
- [terraform/providers.tf](./terraform/providers.tf)
- [terraform/variables.tf](./terraform/variables.tf)
- [terraform/outputs.tf](./terraform/outputs.tf)
- [terraform/versions.tf](./terraform/versions.tf)
- Пример переменных: [terraform/terraform.tfvars.example](./terraform/terraform.tfvars.example)

Скриншоты:
- [screenshots/init.png](./screenshots/init.png) — terraform init
- [screenshots/plan.png](./screenshots/plan.png) — terraform plan
- [screenshots/apply.png](./screenshots/apply.png) — terraform apply
- [screenshots/google_cloud.png](./screenshots/google_cloud.png) — ресурсы в GCP

Коротко о выполнении:
- Подготовлены локальные SSH‑ключи, публичный ключ передаётся через cloud-init (без хардкода в репозитории).
- Описаны сеть/подсети, NAT и правила FW; созданы ВМ: `bastion` (публичный IP), `web-a`, `web-b` (только приватные IP).
- Включена передача cloud-init, блокированы проектные SSH‑ключи; сгенерирован `terraform/hosts.ini` с ProxyCommand.

---

### Задание 2
Подключиться к `web-a` и `web-b` через bastion и установить Nginx; выполнить проверки.

Файлы решения:
- [ansible/ansible.cfg](./ansible/ansible.cfg)
- [ansible/playbooks/nginx_install.yml](./ansible/playbooks/nginx_install.yml)
- [ansible/templates/index.html.j2](./ansible/templates/index.html.j2)

Скриншоты:
- [screenshots/ping.png](./screenshots/ping.png) — ansible ping webservers
- [screenshots/nginx.png](./screenshots/nginx.png) — установка и проверка Nginx
- [screenshots/ssh.png](./screenshots/ssh.png) — SSH/ProxyCommand через bastion (при необходимости)

Коротко о выполнении:
- Inventory берётся из `terraform/hosts.ini`, настроен `ansible_user`, ключ и ProxyCommand через bastion.
- Выполнен `ansible -m ping webservers`; запущен плейбук установки Nginx; проверены статус сервиса и HTTP‑ответ 200.
- Повторный запуск плейбука идемпотентен (изменений нет).

---

Примечания:
- SSH‑ключи и `terraform.tfvars` не коммитятся (см. `.gitignore`).
- `terraform/hosts.ini` генерируется автоматически и в репозиторий не добавляется.

