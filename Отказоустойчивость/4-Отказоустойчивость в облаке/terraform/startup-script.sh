#!/bin/bash

# Обновление пакетов
apt-get update

# Установка Nginx
apt-get install -y nginx

# Получение hostname и IP
HOSTNAME=$(hostname)
INTERNAL_IP=$(hostname -I | awk '{print $1}')

# Создание кастомной страницы
cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nginx Load Balancer Test</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .container {
            background: rgba(255, 255, 255, 0.1);
            border-radius: 10px;
            padding: 30px;
            backdrop-filter: blur(10px);
        }
        h1 {
            text-align: center;
            font-size: 2.5em;
        }
        .info {
            background: rgba(255, 255, 255, 0.2);
            padding: 15px;
            border-radius: 5px;
            margin: 10px 0;
        }
        .label {
            font-weight: bold;
            color: #ffd700;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Nginx Load Balancer Test</h1>
        <div class="info">
            <p><span class="label">Сервер:</span> $HOSTNAME</p>
            <p><span class="label">Внутренний IP:</span> $INTERNAL_IP</p>
            <p><span class="label">Дата и время:</span> $(date)</p>
        </div>
        <p style="text-align: center; margin-top: 30px;">
            ✅ Nginx работает корректно!<br>
            📊 Задание: Отказоустойчивость в облаке<br>
            👨‍💻 Выполнил: Бахаев Андрей
        </p>
    </div>
</body>
</html>
EOF

# Запуск и автозапуск Nginx
systemctl start nginx
systemctl enable nginx

# Проверка статуса
systemctl status nginx

