# Домашнее задание к занятию "Отказоустойчивость в облаке" - `Бахаев Андрей`


### Инструкция по выполнению домашнего задания

   1. Сделайте `fork` данного репозитория к себе в Github и переименуйте его по названию или номеру занятия, например, https://github.com/имя-вашего-репозитория/git-hw или  https://github.com/имя-вашего-репозитория/7-1-ansible-hw).
   2. Выполните клонирование данного репозитория к себе на ПК с помощью команды `git clone`.
   3. Выполните домашнее задание и заполните у себя локально этот файл README.md:
      - впишите вверху название занятия и вашу фамилию и имя
      - в каждом задании добавьте решение в требуемом виде (текст/код/скриншоты/ссылка)
      - для корректного добавления скриншотов воспользуйтесь [инструкцией "Как вставить скриншот в шаблон с решением](https://github.com/netology-code/sys-pattern-homework/blob/main/screen-instruction.md)
      - при оформлении используйте возможности языка разметки md (коротко об этом можно посмотреть в [инструкции  по MarkDown](https://github.com/netology-code/sys-pattern-homework/blob/main/md-instruction.md))
   4. После завершения работы над домашним заданием сделайте коммит (`git commit -m "comment"`) и отправьте его на Github (`git push origin`);
   5. Для проверки домашнего задания преподавателем в личном кабинете прикрепите и отправьте ссылку на решение в виде md-файла в вашем Github.
   6. Любые вопросы по выполнению заданий спрашивайте в чате учебной группы и/или в разделе "Вопросы по заданию" в личном кабинете.
   
Желаем успехов в выполнении домашнего задания!
   
### Дополнительные материалы, которые могут быть полезны для выполнения задания

1. [Руководство по оформлению Markdown файлов](https://gist.github.com/Jekins/2bf2d0638163f1294637#Code)

---

### Цель задания

В результате выполнения этого задания вы научитесь:  
1. Конфигурировать отказоустойчивый кластер в облаке с использованием различных функций отказоустойчивости
2. Устанавливать сервисы из конфигурации инфраструктуры

---

### Чеклист готовности к домашнему заданию

1. Создан аккаунт на YandexCloud
2. Создан новый OAuth-токен
3. Установлено программное обеспечение Terraform

---

### Инструменты и дополнительные материалы

1. [Документация сетевого балансировщика нагрузки](https://cloud.yandex.ru/docs/network-load-balancer/quickstart)

---

### Задание 1

**Задание:**

Возьмите за основу [решение к заданию 1 из занятия «Подъём инфраструктуры в Яндекс Облаке»](https://github.com/netology-code/sdvps-homeworks/blob/main/7-03.md#задание-1).

1. Теперь вместо одной виртуальной машины сделайте terraform playbook, который:

- создаст 2 идентичные виртуальные машины. Используйте аргумент [count](https://www.terraform.io/docs/language/meta-arguments/count.html) для создания таких ресурсов
- создаст [таргет-группу](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/lb_target_group). Поместите в неё созданные на шаге 1 виртуальные машины
- создаст [сетевой балансировщик нагрузки](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/lb_network_load_balancer), который слушает на порту 80, отправляет трафик на порт 80 виртуальных машин и http healthcheck на порт 80 виртуальных машин

Рекомендуем изучить [документацию сетевого балансировщика нагрузки](https://cloud.yandex.ru/docs/network-load-balancer/quickstart) для того, чтобы было понятно, что вы сделали.

2. Установите на созданные виртуальные машины пакет Nginx любым удобным способом и запустите Nginx веб-сервер на порту 80.

3. Перейдите в веб-консоль Yandex Cloud и убедитесь, что: 

- созданный балансировщик находится в статусе Active
- обе виртуальные машины в целевой группе находятся в состоянии healthy

4. Сделайте запрос на 80 порт на внешний IP-адрес балансировщика и убедитесь, что вы получаете ответ в виде дефолтной страницы Nginx.

**В качестве результата пришлите:**

1. Terraform Playbook
2. Скриншот статуса балансировщика и целевой группы
3. Скриншот страницы, которая открылась при запросе IP-адреса балансировщика

**Решение:**

Задание выполнено в Google Cloud Platform (проект: `n8n-prod-461317`, регион: `europe-west3`).

**Адаптация задания для GCP:**

Вместо Yandex Cloud использован Google Cloud Platform с аналогичными сервисами:
- **Compute Engine** вместо Yandex Compute
- **HTTP(S) Load Balancer** вместо сетевого балансировщика Yandex
- **Backend Service с Health Checks** для проверки состояния серверов

**Этапы выполнения:**

### 1. Создание Terraform конфигурации

Создана инфраструктура как код (IaC) с использованием Terraform:

**Структура проекта:**
```
terraform/
├── provider.tf        # Конфигурация провайдера GCP
├── variables.tf       # Переменные проекта
├── network.tf         # Настройка сети и firewall
├── compute.tf         # Виртуальные машины
├── load_balancer.tf   # Балансировщик нагрузки
├── outputs.tf         # Вывод результатов
├── startup-script.sh  # Скрипт установки Nginx
└── .gitignore        # Исключения для Git
```

### 2. Архитектура решения

**Созданные ресурсы:**

1. **2 виртуальные машины** (e2-micro, Ubuntu 22.04)
   - С автоматической установкой Nginx через startup-script
   - С тегами для firewall rules
   - В зоне europe-west3-c

2. **Instance Group** — группа для управления VM

3. **Health Check** — HTTP проверка на порту 80 (интервал 5 сек)

4. **Backend Service** — сервис распределения нагрузки
   - Алгоритм балансировки: UTILIZATION
   - Подключен health check

5. **HTTP(S) Load Balancer:**
   - URL Map для маршрутизации
   - HTTP Proxy
   - Статический внешний IP
   - Forwarding Rule на порту 80

6. **Firewall Rules:**
   - Разрешение HTTP трафика (0.0.0.0/0 → порт 80)
   - Разрешение health checks (35.191.0.0/16, 130.211.0.0/22 → порт 80)

### 3. Автоматическая установка Nginx

Создан startup script для автоматической установки Nginx при создании VM:

```bash
#!/bin/bash
apt-get update
apt-get install -y nginx
systemctl start nginx
systemctl enable nginx

# Создание кастомной страницы с информацией о сервере
HOSTNAME=$(hostname)
INTERNAL_IP=$(hostname -I | awk '{print $1}')
cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head><title>Nginx Load Balancer Test</title></head>
<body>
  <h1>Nginx Load Balancer Test</h1>
  <p>Сервер: $HOSTNAME</p>
  <p>Внутренний IP: $INTERNAL_IP</p>
  <p>Выполнил: Бахаев Андрей</p>
</body>
</html>
EOF
```

### 4. Применение конфигурации

```bash
cd terraform/
terraform init
terraform validate
terraform plan
terraform apply  # Подтвердить: yes
```

**Результат применения:**
- Созданы 2 VM: `web-server-1`, `web-server-2`
- Создан Load Balancer с внешним IP
- Health checks HEALTHY для обеих VM
- Nginx доступен через балансировщик

### 5. Проверка работоспособности

**Проверка health checks:**
```bash
gcloud compute backend-services get-health web-backend-service --global
```

Результат:
```
backend: https://www.googleapis.com/compute/v1/projects/.../web-servers-group
status:
  healthStatus:
  - healthState: HEALTHY
    instance: https://.../web-server-1
  - healthState: HEALTHY
    instance: https://.../web-server-2
```

**Проверка балансировки:**
```bash
for i in {1..10}; do 
  curl -s http://<LB_IP> | grep "Сервер:"
done
```

Результат: ответы приходят попеременно от `web-server-1` и `web-server-2`.

**Terraform Playbook:**

<details>
<summary>provider.tf</summary>

```hcl
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0"
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}
```
</details>

<details>
<summary>variables.tf</summary>

```hcl
variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "n8n-prod-461317"
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "europe-west3"
}

variable "zone" {
  description = "GCP Zone"
  type        = string
  default     = "europe-west3-c"
}

variable "instance_count" {
  description = "Number of VM instances"
  type        = number
  default     = 2
}

variable "machine_type" {
  description = "Machine type for instances"
  type        = string
  default     = "e2-micro"
}

variable "instance_name_prefix" {
  description = "Prefix for instance names"
  type        = string
  default     = "web-server"
}
```
</details>

<details>
<summary>compute.tf</summary>

```hcl
resource "google_compute_instance" "web_server" {
  count        = var.instance_count
  name         = "${var.instance_name_prefix}-${count.index + 1}"
  machine_type = var.machine_type
  zone         = var.zone

  tags = ["http-server", "web-server"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 10
    }
  }

  network_interface {
    network = data.google_compute_network.default.name
    access_config {}
  }

  metadata = {
    startup-script = file("${path.module}/startup-script.sh")
  }

  allow_stopping_for_update = true
}
```
</details>

<details>
<summary>load_balancer.tf</summary>

```hcl
resource "google_compute_health_check" "http_health_check" {
  name                = "http-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2

  http_health_check {
    port         = 80
    request_path = "/"
  }
}

resource "google_compute_instance_group" "web_servers" {
  name      = "web-servers-group"
  zone      = var.zone
  instances = google_compute_instance.web_server[*].self_link

  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_backend_service" "web_backend" {
  name          = "web-backend-service"
  protocol      = "HTTP"
  port_name     = "http"
  health_checks = [google_compute_health_check.http_health_check.id]

  backend {
    group          = google_compute_instance_group.web_servers.id
    balancing_mode = "UTILIZATION"
  }
}

resource "google_compute_url_map" "web_url_map" {
  name            = "web-url-map"
  default_service = google_compute_backend_service.web_backend.id
}

resource "google_compute_target_http_proxy" "web_proxy" {
  name    = "web-http-proxy"
  url_map = google_compute_url_map.web_url_map.id
}

resource "google_compute_global_address" "lb_ip" {
  name = "web-lb-ip"
}

resource "google_compute_global_forwarding_rule" "http_forwarding_rule" {
  name       = "http-forwarding-rule"
  target     = google_compute_target_http_proxy.web_proxy.id
  port_range = "80"
  ip_address = google_compute_global_address.lb_ip.address
}
```
</details>

Полная конфигурация доступна в директории `terraform/`.

**Скриншоты:**

![Скриншот 1 - Статус балансировщика и backend service](screenshots/load_balancer.png)

![Скриншот 2 - Health checks (HEALTHY status)](screenshots/health_checks.png)

![Скриншот 3 - Виртуальные машины в GCP](screenshots/vm_instances.png)

![Скриншот 4 - Страница Nginx через балансировщик (web-server-1)](screenshots/nginx_server1.png)

![Скриншот 5 - Страница Nginx через балансировщик (web-server-2)](screenshots/nginx_server2.png)

![Скриншот 6 - Terraform outputs](screenshots/terraform_output.png)

---

### Правила приема работы

1. Необходимо следовать инструкции по выполнению домашнего задания, используя для оформления репозиторий Github
2. В ответе необходимо прикладывать требуемые материалы - скриншоты, конфигурационные файлы, скрипты. Необходимые материалы для получения зачета указаны в каждом задании

---

### Критерии оценки

- Зачет - выполнены все задания, ответы даны в развернутой форме, приложены требуемые скриншоты, конфигурационные файлы, скрипты. В выполненных заданиях нет противоречий и нарушения логики
- На доработку - задание выполнено частично или не выполнено, в логике выполнения заданий есть противоречия, существенные недостатки, приложены не все требуемые материалы


