# Terraform конфигурация для отказоустойчивой инфраструктуры в GCP

## Описание

Эта конфигурация создает отказоустойчивую инфраструктуру в Google Cloud Platform:
- 2 виртуальные машины с Nginx
- HTTP(S) Load Balancer
- Health Checks для мониторинга состояния серверов
- Firewall Rules для доступа

## Предварительные требования

1. Google Cloud SDK установлен и настроен
2. Terraform >= 1.0 установлен
3. Активный проект в GCP (`n8n-prod-461317`)
4. Настроены права доступа

## Быстрый старт

### 1. Инициализация

```bash
terraform init
```

### 2. Проверка конфигурации

```bash
terraform validate
terraform plan
```

### 3. Применение конфигурации

```bash
terraform apply
```

Подтвердите создание ресурсов, введя `yes`.

### 4. Ожидание

Подождите 3-5 минут для:
- Установки Nginx на серверах
- Прохождения health checks
- Активации балансировщика

### 5. Проверка

```bash
# Получить IP балансировщика
terraform output load_balancer_ip

# Проверить доступность
curl http://$(terraform output -raw load_balancer_ip)

# Проверить балансировку (должны быть ответы от разных серверов)
for i in {1..10}; do 
  curl -s http://$(terraform output -raw load_balancer_ip) | grep "Сервер:"
done
```

### 6. Проверка health checks

```bash
gcloud compute backend-services get-health web-backend-service --global
```

## Структура файлов

- `provider.tf` — конфигурация провайдера GCP
- `variables.tf` — переменные проекта
- `network.tf` — настройка сети и firewall
- `compute.tf` — виртуальные машины
- `load_balancer.tf` — балансировщик нагрузки
- `outputs.tf` — вывод результатов
- `startup-script.sh` — скрипт установки Nginx

## Создаваемые ресурсы

1. **Compute Instances (2 шт.)** — виртуальные машины с Ubuntu 22.04 и Nginx
2. **Instance Group** — группа для управления VM
3. **Health Check** — проверка работоспособности на порту 80
4. **Backend Service** — сервис для распределения нагрузки
5. **URL Map** — маршрутизация запросов
6. **HTTP Proxy** — прокси для обработки HTTP
7. **Global IP Address** — статический внешний IP
8. **Forwarding Rule** — правило переадресации трафика
9. **Firewall Rules (2 шт.)** — правила для HTTP и health checks

## Стоимость

Примерная стоимость при использовании 1 час:
- 2 x e2-micro VM: ~$0.02
- HTTP(S) Load Balancer: ~$0.05
- Traffic: минимальный
- **Итого:** ~$0.10-0.15/час

## Очистка ресурсов

⚠️ **ВАЖНО:** После выполнения задания удалите ресурсы, чтобы не платить!

```bash
terraform destroy
```

Подтвердите удаление, введя `yes`.

## Troubleshooting

### Проблема: Health checks UNHEALTHY

**Решение:**
1. Подождите 5-10 минут
2. Проверьте, что Nginx запущен:
   ```bash
   gcloud compute ssh web-server-1 --zone=europe-west3-c --command="sudo systemctl status nginx"
   ```
3. Проверьте firewall rules:
   ```bash
   gcloud compute firewall-rules list
   ```

### Проблема: 502 Bad Gateway

**Причина:** Health checks еще не прошли

**Решение:** Подождите 3-5 минут и повторите

### Проблема: Terraform apply завершается с ошибкой

**Решение:**
1. Проверьте авторизацию: `gcloud auth application-default login`
2. Проверьте проект: `gcloud config get-value project`
3. Проверьте права доступа в GCP Console

## Веб-консоль GCP

После создания инфраструктуры откройте:

- **Load Balancer:** https://console.cloud.google.com/net-services/loadbalancing/list/loadBalancers
- **VM Instances:** https://console.cloud.google.com/compute/instances
- **Health Checks:** https://console.cloud.google.com/compute/healthChecks

## Автор

Бахаев Андрей  
Задание: Отказоустойчивость в облаке  
Курс: Netology DevOps

