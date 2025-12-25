# Runbook: деплой и проверки по шагам

Документ описывает порядок действий и проверки для каждого требования курсовой работы.

## 0. Подготовка окружения
1. Задать переменные окружения `YC_TOKEN`, `YC_CLOUD_ID`, `YC_FOLDER_ID` или заполнить `terraform.tfvars` на основе примера.
2. Создать Python venv и установить зависимости:
   ```bash
   python3 -m venv .venv
   source .venv/bin/activate
   pip install -r requirements.txt
   ```
3. Проверить формат и синтаксис: `make verify`.

**Проверка:** `terraform -chdir=terraform validate` + `ansible-lint` проходят без ошибок.

## 1. Развёртывание базовой инфраструктуры (VPC, подсети, SG, ВМ, ALB, snapshots)
1. `make tf-init`
2. `make tf-plan`
3. `make tf-apply`

**Проверки по требованиям:**
- `yc vpc network list` → существует одна VPC.
- `yc vpc subnet list` → 2 приватные и 2 публичные подсети в разных зонах.
- `terraform output alb_public_ip` → сохранить IP балансера.
- `yc compute snapshot-schedule list` → есть расписание `daily-snapshots` с retention 7 дней.

## 2. Генерация Ansible inventory и проверка доступности bastion
1. Создать inventory вручную на основе Terraform outputs:
   ```bash
   terraform -chdir=terraform output -json > /tmp/tf_output.json
   # Используйте значения из outputs для создания inventory/hosts.yml
   # Или используйте скрипт из _archive/scripts/render-inventory.sh
   ```
2. Проверить, что bastion прописан в inventory.
3. `make ansible-ping`

**Проверка:** приватные хосты пингуются через ProxyCommand (SSH идёт только через bastion, требование «один публичный SSH-порт» выполнено).

## 3. Настройка веб-сервера и сайта
1. `make ansible-site` запускает все роли; при необходимости можно ограничить: `ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook -i inventory/hosts.json ansible/playbooks/site.yml --limit web`.
2. После завершения — запросить сайт через балансер: `curl -v http://$(terraform -chdir=terraform output -raw alb_public_ip)/`.

**Проверки:**
- Ответ 200 OK и страница «Отказоустойчивая инфраструктура» (требование «сайт доступен через ALB»).
- `yc alb target-group list-targets --id $(terraform output -raw target_group_id)` → оба веб-хоста `healthy`.

## 4. Мониторинг
1. Prometheus и exporters разворачиваются ролью `prometheus` и `node_exporter`.
2. Проверить Prometheus targets: `ssh ubuntu@bastion -L 9090:<prometheus_ip>:9090` и открыть `http://localhost:9090/targets`.
3. Grafana: открыть `http://$(terraform -chdir=terraform output -raw grafana_public_ip):3000`, логин и пароль указаны в `ansible/group_vars/all.yml`, убедиться что datasource подключён и дашборд USE отображает метрики.

**Критерии:**
- На дашборде есть CPU/RAM/disk/net + http_response_count_total.
- На графиках настроены пороги (красная зона >85%).

## 5. Логи
1. Elasticsearch: `ssh -J ubuntu@<bastion_ip> ubuntu@<elasticsearch_ip> curl -s localhost:9200/_cluster/health` → статус `green`.
2. Kibana: `http://$(terraform -chdir=terraform output -raw kibana_public_ip):5601` → создать index pattern `filebeat-*`.
3. Filebeat: `sudo filebeat test output` на одном из веб-хостов.

**Проверка:** в Kibana отображаются записи access.log / error.log; см. скриншот в `docs/screenshots/`.

## 6. Сеть и безопасность
- Проверить, что `nc -vz <web_ip> 22` извне не доступен (только через bastion).
- Из ALB healthcheck доступен порт 80 на каждом веб-сервере.
- Security groups содержат только требуемые порты (`yc vpc security-group get <id>`).

## 7. Резервное копирование
- `yc compute snapshot-schedule get $(terraform -chdir=terraform output -raw snapshot_schedule_id)` — cron `0 3 * * *`, TTL = 7.
- После первого дня: `yc compute snapshot list --filter="labels.purpose='daily-backup'"` — появятся снапшоты всех дисков.

## 8. Документация и демонстрация
- Собрать curl-выводы и скриншоты Grafana/Kibana/Prometheus/snaphots в `docs/screenshots/`.
- Обновить `README.md` репозитория ссылками на публичные IP или приложить доказательства.

Каждое действие сопровождается проверкой, подтверждающей выполнение пункта ТЗ, что позволяет сдавать курсовую работу с прозрачной трассировкой.
