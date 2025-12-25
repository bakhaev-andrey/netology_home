#!/usr/bin/env bash
# Скрипт для автоматической настройки переменных окружения из YC CLI
set -euo pipefail

if ! command -v yc >/dev/null 2>&1; then
    echo "Ошибка: Yandex Cloud CLI (yc) не установлен" >&2
    echo "Установите: https://cloud.yandex.ru/docs/cli/quickstart" >&2
    exit 1
fi

echo "Получение настроек из YC CLI..."

YC_TOKEN=$(yc config get token 2>/dev/null || echo "")
YC_CLOUD_ID=$(yc config get cloud-id 2>/dev/null || echo "")
YC_FOLDER_ID=$(yc config get folder-id 2>/dev/null || echo "")

if [ -z "$YC_TOKEN" ] || [ -z "$YC_CLOUD_ID" ] || [ -z "$YC_FOLDER_ID" ]; then
    echo "Ошибка: Не все настройки найдены в yc config" >&2
    echo "Выполните: yc init" >&2
    exit 1
fi

# Установка переменных окружения для Terraform
export TF_VAR_yc_token="$YC_TOKEN"
export TF_VAR_yc_cloud_id="$YC_CLOUD_ID"
export TF_VAR_yc_folder_id="$YC_FOLDER_ID"

echo "✓ Переменные окружения установлены:"
echo "  TF_VAR_yc_token: ${YC_TOKEN:0:20}..."
echo "  TF_VAR_yc_cloud_id: $YC_CLOUD_ID"
echo "  TF_VAR_yc_folder_id: $YC_FOLDER_ID"
echo ""
echo "Для использования в текущей сессии выполните:"
echo "  source scripts/setup-env.sh"
echo ""
echo "Или добавьте в ~/.bashrc или ~/.zshrc:"
echo "  export TF_VAR_yc_token=\$(yc config get token)"
echo "  export TF_VAR_yc_cloud_id=\$(yc config get cloud-id)"
echo "  export TF_VAR_yc_folder_id=\$(yc config get folder-id)"

