# Команды для выполнения Задания 1

## Предварительная настройка

```bash
# Перейти в директорию с Terraform
cd "/Users/andrey/SciFlow/netology_homework/Отказоустойчивость/4-Отказоустойчивость в облаке/terraform"

# Проверить авторизацию в GCP
gcloud auth list
gcloud config get-value project
```

## Применение конфигурации

```bash
# 1. Инициализация Terraform
terraform init

# 2. Проверка конфигурации
terraform validate

# 3. Просмотр плана изменений
terraform plan

# 4. Применение конфигурации (СОЗДАСТ РЕСУРСЫ В ОБЛАКЕ!)
terraform apply
```

**⚠️ ВНИМАНИЕ:** Команда `terraform apply` создаст реальные ресурсы в Google Cloud и начнет списание средств!

Примерная стоимость: $0.10-0.15/час

## После применения (подождать 3-5 минут)

```bash
# Получить IP балансировщика
terraform output -raw load_balancer_ip

# Проверить health checks
gcloud compute backend-services get-health web-backend-service --global

# Проверить доступность
curl http://$(terraform output -raw load_balancer_ip)

# Проверить балансировку
for i in {1..10}; do 
  curl -s http://$(terraform output -raw load_balancer_ip) | grep "Сервер:"
done
```

## Скриншоты

Открыть в браузере:
1. https://console.cloud.google.com/net-services/loadbalancing?project=n8n-prod-461317
2. https://console.cloud.google.com/compute/instances?project=n8n-prod-461317
3. http://<IP_БАЛАНСИРОВЩИКА>

## Очистка ресурсов (ОБЯЗАТЕЛЬНО после выполнения!)

```bash
terraform destroy
```
