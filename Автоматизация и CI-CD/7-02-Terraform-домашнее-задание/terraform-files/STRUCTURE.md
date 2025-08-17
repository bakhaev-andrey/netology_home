# Структура примеров Terraform из wallarm/terraform-example

## 📁 Основные файлы

- **main.tf** - Основной файл конфигурации Terraform
- **variables.tf** - Определение переменных
- **outputs.tf** - Выходные значения
- **versions.tf** - Версии провайдеров и Terraform
- **wallarm-example-README.md** - Описание примера из репозитория

## 📁 Модули

### autoscaling/
- **autoscaling-main.tf** - Основная логика автомасштабирования
- **autoscaling-variables.tf** - Переменные для модуля автомасштабирования

### network/
- **network-main.tf** - Настройка сетевой инфраструктуры
- **network-variables.tf** - Переменные для сетевого модуля

## 🔍 Анализ примера

Этот пример демонстрирует:
- Развертывание кластера автомасштабирования WAF узлов в AWS
- Модульную архитектуру Terraform
- Использование провайдера AWS
- Настройку Auto Scaling Groups
- Конфигурацию VPC и подсетей

## 📚 Полезные ссылки

- [Оригинальный репозиторий](https://github.com/wallarm/terraform-example)
- [Документация Terraform](https://www.terraform.io/docs)
- [AWS Provider для Terraform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## ⚠️ Примечание

Некоторые файлы могут быть пустыми или содержать минимальный код, так как репозиторий был архивирован в 2022 году. Рекомендуется использовать для изучения структуры и подходов, а не для прямого копирования в продакшн.
