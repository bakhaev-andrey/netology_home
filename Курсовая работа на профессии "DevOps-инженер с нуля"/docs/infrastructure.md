# Техническое описание инфраструктуры

## Общая информация

- **Облачный провайдер:** Yandex Cloud
- **VPC сеть:** `n8n-network` (использована существующая из-за лимита)
- **Зоны доступности:** `ru-central1-a`, `ru-central1-b`
- **Платформа:** `standard-v3`
- **Образ ОС:** `ubuntu-2204-lts`

## Сетевая инфраструктура

### Подсети

| Подсеть | Зона | CIDR | Тип | Назначение |
|---------|------|------|-----|------------|
| `public-ru-central1-a` | `ru-central1-a` | `10.70.10.0/24` | Публичная | Bastion, Grafana |
| `public-ru-central1-b` | `ru-central1-b` | `10.70.11.0/24` | Публичная | Kibana |
| `private-ru-central1-a` | `ru-central1-a` | `10.70.1.0/24` | Приватная | Web-A, Prometheus |
| `private-ru-central1-b` | `ru-central1-b` | `10.70.2.0/24` | Приватная | Web-B, Elasticsearch |

### Security Groups

| Security Group | Назначение | Входящие порты | Источники |
|----------------|------------|----------------|-----------|
| `sg-bastion` | Bastion Host | 22/tcp | Интернет (0.0.0.0/0) |
| `sg-web` | Веб-серверы | 22/tcp, 80/tcp, 9100/tcp, 4040/tcp | Bastion SG, ALB, Prometheus SG |
| `sg-prometheus` | Prometheus | 22/tcp, 9090/tcp | Bastion SG, Grafana SG |
| `sg-grafana` | Grafana | 22/tcp, 3000/tcp | Интернет (0.0.0.0/0), Bastion SG |
| `sg-elasticsearch` | Elasticsearch | 22/tcp, 9200/tcp | Bastion SG, Kibana SG, Web SG |
| `sg-kibana` | Kibana | 22/tcp, 5601/tcp | Интернет (0.0.0.0/0), Bastion SG |
| `sg-alb` | Application Load Balancer | 80/tcp | Интернет (0.0.0.0/0), ALB health checks |

## Виртуальные машины

### 1. Bastion Host

**Назначение:** Единственная точка входа для SSH доступа ко всем приватным хостам

| Параметр | Значение |
|----------|----------|
| **Имя** | `bastion` |
| **Hostname** | `bastion` |
| **Зона** | `ru-central1-a` |
| **Подсеть** | `public-ru-central1-a` (10.70.10.0/24) |
| **Публичный IP** | `62.84.124.19` |
| **Приватный IP** | `10.70.10.x` |
| **CPU** | 2 vCPU |
| **RAM** | 2 GB |
| **Диск** | 20 GB |
| **Security Group** | `sg-bastion` |
| **Порты** | 22/tcp (SSH) |
| **ОС** | Ubuntu 22.04 LTS |

**Доступ:**
```bash
ssh ubuntu@62.84.124.19
```

**Роль Ansible:** `bastion` - настройка SSH jump host

---

### 2. Web Servers (2x)

**Назначение:** Веб-серверы с nginx, Node Exporter, Nginx Log Exporter, Filebeat

#### Web-A

| Параметр | Значение |
|----------|----------|
| **Имя** | `web-ru-central1-a` |
| **Hostname** | `web-ru-central1-a` |
| **Зона** | `ru-central1-a` |
| **Подсеть** | `private-ru-central1-a` (10.70.1.0/24) |
| **Приватный IP** | `10.70.1.26` |
| **CPU** | 2 vCPU |
| **RAM** | 2 GB |
| **Диск** | 20 GB |
| **Security Group** | `sg-web` |
| **Порты** | 22/tcp (SSH), 80/tcp (HTTP), 9100/tcp (Node Exporter), 4040/tcp (Nginx Log Exporter) |
| **ОС** | Ubuntu 22.04 LTS |

#### Web-B

| Параметр | Значение |
|----------|----------|
| **Имя** | `web-ru-central1-b` |
| **Hostname** | `web-ru-central1-b` |
| **Зона** | `ru-central1-b` |
| **Подсеть** | `private-ru-central1-b` (10.70.2.0/24) |
| **Приватный IP** | `10.70.2.23` |
| **CPU** | 2 vCPU |
| **RAM** | 2 GB |
| **Диск** | 20 GB |
| **Security Group** | `sg-web` |
| **Порты** | 22/tcp (SSH), 80/tcp (HTTP), 9100/tcp (Node Exporter), 4040/tcp (Nginx Log Exporter) |
| **ОС** | Ubuntu 22.04 LTS |

**Установленное ПО:**
- **Nginx** - веб-сервер
- **Node Exporter** v1.6.1 - метрики системы
- **Nginx Log Exporter** v1.11.0 - метрики HTTP запросов
- **Filebeat** v8.11.3 (Docker) - отправка логов в Elasticsearch

**Роль Ansible:** `web`, `node_exporter`, `nginx_log_exporter`, `filebeat`

**Доступ:**
```bash
# Через bastion
ssh -J ubuntu@62.84.124.19 ubuntu@10.70.1.26  # web-a
ssh -J ubuntu@62.84.124.19 ubuntu@10.70.2.23  # web-b
```

---

### 3. Prometheus

**Назначение:** Сбор и хранение метрик

| Параметр | Значение |
|----------|----------|
| **Имя** | `prometheus` |
| **Hostname** | `prometheus` |
| **Зона** | `ru-central1-a` |
| **Подсеть** | `private-ru-central1-a` (10.70.1.0/24) |
| **Приватный IP** | `10.70.1.27` |
| **CPU** | 2 vCPU |
| **RAM** | 4 GB |
| **Диск** | 30 GB |
| **Security Group** | `sg-prometheus` |
| **Порты** | 22/tcp (SSH), 9090/tcp (Prometheus UI) |
| **ОС** | Ubuntu 22.04 LTS |

**Установленное ПО:**
- **Prometheus** v2.49.0
- **Retention:** 15 дней
- **Scrape interval:** 15 секунд

**Targets:**
- `node_exporter` на web-a и web-b (порт 9100)
- `nginx_log_exporter` на web-a и web-b (порт 4040)
- `prometheus` self-monitoring

**Роль Ansible:** `prometheus`

**Доступ:**
```bash
# Через bastion с SSH туннелем
ssh -J ubuntu@62.84.124.19 -L 9090:10.70.1.27:9090 ubuntu@10.70.1.27
# Затем открыть http://localhost:9090
```

---

### 4. Grafana

**Назначение:** Визуализация метрик

| Параметр | Значение |
|----------|----------|
| **Имя** | `grafana` |
| **Hostname** | `grafana` |
| **Зона** | `ru-central1-a` |
| **Подсеть** | `public-ru-central1-a` (10.70.10.0/24) |
| **Публичный IP** | `130.193.36.77` |
| **Приватный IP** | `10.70.10.x` |
| **CPU** | 2 vCPU |
| **RAM** | 2 GB |
| **Диск** | 20 GB |
| **Security Group** | `sg-grafana` |
| **Порты** | 22/tcp (SSH), 3000/tcp (Grafana UI) |
| **ОС** | Ubuntu 22.04 LTS |

**Установленное ПО:**
- **Grafana** v10.4.0 (Docker)
- **Datasource:** Prometheus (http://10.70.1.27:9090)
- **Dashboards:** USE метрики (CPU, RAM, Disk, Network, HTTP)

**Роль Ansible:** `grafana`

**Доступ:**
- **URL:** http://130.193.36.77:3000
- **Логин:** `admin`
- **Пароль:** см. `ansible/group_vars/all.yml`

---

### 5. Elasticsearch

**Назначение:** Хранение и индексация логов

| Параметр | Значение |
|----------|----------|
| **Имя** | `elasticsearch` |
| **Hostname** | `elasticsearch` |
| **Зона** | `ru-central1-b` |
| **Подсеть** | `private-ru-central1-b` (10.70.2.0/24) |
| **Приватный IP** | `10.70.2.15` |
| **CPU** | 4 vCPU |
| **RAM** | 8 GB |
| **Диск** | 50 GB |
| **Security Group** | `sg-elasticsearch` |
| **Порты** | 22/tcp (SSH), 9200/tcp (Elasticsearch API) |
| **ОС** | Ubuntu 22.04 LTS |

**Установленное ПО:**
- **Elasticsearch** v8.11.3 (Docker)
- **Heap size:** 2 GB
- **Кластер:** Single-node

**Статистика:**
- **Документов:** 30,350+
- **Индексы:** `filebeat-2025.12.25`
- **Размер данных:** ~2.8 MB

**Роль Ansible:** `elasticsearch`

**Доступ:**
```bash
# Через bastion
ssh -J ubuntu@62.84.124.19 ubuntu@10.70.2.15
curl http://localhost:9200/_cat/indices
```

---

### 6. Kibana

**Назначение:** Визуализация и анализ логов

| Параметр | Значение |
|----------|----------|
| **Имя** | `kibana` |
| **Hostname** | `kibana` |
| **Зона** | `ru-central1-b` |
| **Подсеть** | `public-ru-central1-b` (10.70.11.0/24) |
| **Публичный IP** | `158.160.92.149` |
| **Приватный IP** | `10.70.11.x` |
| **CPU** | 2 vCPU |
| **RAM** | 4 GB |
| **Диск** | 20 GB |
| **Security Group** | `sg-kibana` |
| **Порты** | 22/tcp (SSH), 5601/tcp (Kibana UI) |
| **ОС** | Ubuntu 22.04 LTS |

**Установленное ПО:**
- **Kibana** v8.11.3 (Docker)
- **Elasticsearch endpoint:** http://10.70.2.15:9200
- **Index Pattern:** `filebeat-*`

**Роль Ansible:** `kibana`

**Доступ:**
- **URL:** http://158.160.92.149:5601

---

## Application Load Balancer

**Назначение:** Распределение HTTP трафика между веб-серверами

| Параметр | Значение |
|----------|----------|
| **Публичный IP** | `158.160.199.9` |
| **Порт** | 80/tcp (HTTP) |
| **Listener type** | HTTP |
| **Target Group** | `web` (2 хоста) |
| **Healthcheck** | `/` порт 80, протокол HTTP |
| **Backend Group** | `web-backend` |

**Target Group:**
- `web-ru-central1-a` (10.70.1.26) - статус: `healthy`
- `web-ru-central1-b` (10.70.2.23) - статус: `healthy`

**Доступ:**
- **URL:** http://158.160.199.9

---

## Резервное копирование

**Snapshot Schedule:**

| Параметр | Значение |
|----------|----------|
| **Имя** | `daily-snapshots` |
| **Расписание (Cron)** | `0 3 * * *` (ежедневно в 03:00 UTC) |
| **Retention period** | 7 дней (604800 секунд) |
| **Покрытие** | Все 7 дисков всех ВМ |

**Покрываемые диски:**
1. Bastion boot disk
2. Web-A boot disk
3. Web-B boot disk
4. Prometheus boot disk
5. Grafana boot disk
6. Elasticsearch boot disk
7. Kibana boot disk

**Проверка:**
```bash
yc compute snapshot-schedule list
yc compute snapshot-schedule get <schedule_id>
yc compute snapshot list --filter="labels.purpose='daily-backup'"
```

---

## Версии ПО

| Компонент | Версия | Способ установки |
|-----------|--------|------------------|
| **Ubuntu** | 22.04 LTS | Образ Yandex Cloud |
| **Nginx** | Latest (из репозитория) | APT |
| **Node Exporter** | 1.6.1 | Binary |
| **Nginx Log Exporter** | 1.11.0 | Binary |
| **Prometheus** | 2.49.0 | Binary |
| **Grafana** | 10.4.0 | Docker |
| **Elasticsearch** | 8.11.3 | Docker |
| **Kibana** | 8.11.3 | Docker |
| **Filebeat** | 8.11.3 | Docker |

---

## Порты и протоколы

| Сервис | Порт | Протокол | Доступность | Назначение |
|--------|------|----------|-------------|------------|
| **Bastion** | 22 | TCP | Публичный | SSH |
| **Web** | 80 | TCP | Через ALB | HTTP (nginx) |
| **Web** | 9100 | TCP | Приватный | Node Exporter |
| **Web** | 4040 | TCP | Приватный | Nginx Log Exporter |
| **Prometheus** | 9090 | TCP | Приватный | Prometheus UI |
| **Grafana** | 3000 | TCP | Публичный | Grafana UI |
| **Elasticsearch** | 9200 | TCP | Приватный | Elasticsearch API |
| **Kibana** | 5601 | TCP | Публичный | Kibana UI |
| **ALB** | 80 | TCP | Публичный | HTTP балансировщик |

---

## Пути и директории

| Сервис | Путь | Назначение |
|--------|------|------------|
| **Web** | `/var/www/diploma` | Корень сайта |
| **Web** | `/var/log/nginx/access.log` | Логи доступа nginx |
| **Web** | `/var/log/nginx/error.log` | Логи ошибок nginx |
| **Prometheus** | `/etc/prometheus` | Конфигурация Prometheus |
| **Prometheus** | `/var/lib/prometheus` | Данные Prometheus |
| **Grafana** | `/etc/grafana` | Конфигурация Grafana |
| **Grafana** | `/var/lib/grafana` | Данные Grafana |

---

## Конфигурационные файлы

### Terraform
- `terraform/variables.tf` - переменные инфраструктуры
- `terraform/compute.tf` - определение ВМ
- `terraform/network.tf` - сеть и подсети
- `terraform/security-groups.tf` - Security Groups
- `terraform/alb.tf` - Application Load Balancer
- `terraform/snapshots.tf` - Snapshot schedules

### Ansible
- `ansible/group_vars/all.yml` - общие переменные (версии ПО, пароли)
- `ansible/playbooks/site.yml` - главный плейбук
- `ansible/roles/*/tasks/main.yml` - задачи для каждой роли

---

## Мониторинг и логи

### Метрики (Prometheus)

**Targets:**
- `node_exporter` на web-a:9100 - UP
- `node_exporter` на web-b:9100 - UP
- `nginx_log_exporter` на web-a:4040 - UP
- `nginx_log_exporter` на web-b:4040 - UP
- `prometheus` self-monitoring - UP

**Метрики:**
- CPU utilization, saturation, errors
- Memory utilization, saturation
- Disk I/O, utilization
- Network I/O
- HTTP request count, response size

### Логи (Elasticsearch/Kibana)

**Источники:**
- `/var/log/nginx/access.log` - логи доступа nginx
- `/var/log/nginx/error.log` - логи ошибок nginx

**Индексы:**
- `filebeat-2025.12.25` - 30,350+ документов

**Index Pattern:**
- `filebeat-*`

---

## Доступ к сервисам

### Публичный доступ

| Сервис | URL | Порт |
|--------|-----|------|
| **Сайт** | http://158.160.199.9 | 80 |
| **Grafana** | http://130.193.36.77:3000 | 3000 |
| **Kibana** | http://158.160.92.149:5601 | 5601 |

### Доступ через Bastion

| Сервис | Команда SSH |
|--------|-------------|
| **Web-A** | `ssh -J ubuntu@62.84.124.19 ubuntu@10.70.1.26` |
| **Web-B** | `ssh -J ubuntu@62.84.124.19 ubuntu@10.70.2.23` |
| **Prometheus** | `ssh -J ubuntu@62.84.124.19 -L 9090:10.70.1.27:9090 ubuntu@10.70.1.27` |
| **Elasticsearch** | `ssh -J ubuntu@62.84.124.19 ubuntu@10.70.2.15` |

---

## Резюме

**Всего ресурсов:**
- **ВМ:** 6 (bastion, 2x web, prometheus, grafana, elasticsearch, kibana)
- **Подсети:** 4 (2 публичные, 2 приватные)
- **Security Groups:** 7
- **ALB:** 1
- **Snapshot Schedule:** 1

**Общие характеристики:**
- **CPU:** 16 vCPU (суммарно)
- **RAM:** 22 GB (суммарно)
- **Диск:** 180 GB (суммарно)

**Статус:**
- ✅ Все сервисы работают
- ✅ Мониторинг активен (5 targets UP)
- ✅ Логи собираются (30,350+ документов)
- ✅ Резервное копирование настроено

