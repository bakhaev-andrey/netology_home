# Чек-лист валидации

| № | Этап | Команда/Действие | Ожидаемый результат |
|---|------|------------------|---------------------|
| 1 | Подготовка | `make verify` | Terraform fmt/validate + ansible-lint проходят |
| 2 | Сеть | `yc vpc subnet list` | 4 подсети (2 public, 2 private) в двух зонах |
| 3 | Бастион | `ssh ubuntu@<bastion_ip>` | Единственный публичный SSH, доступ открыт только по указанному CIDR |
| 4 | Web + ALB | `curl -v http://<alb_public_ip>/` | HTTP 200, загружается статическая страница |
| 5 | Target Group | `yc alb target-group list-targets --id <target_group_id>` | Оба веб-сервера `HEALTHY` |
| 6 | Мониторинг | `curl http://<prometheus_ip>:9090/targets` через SSH-туннель | Targets `node_exporter` и `nginx_log_exporter` в состоянии `UP` |
| 7 | Grafana | Вход по `http://<grafana_public_ip>:3000` | Дашборд USE отображается, пороги окрашиваются при превышении |
| 8 | Логи | `curl http://<elasticsearch_ip>:9200/_cat/indices` | Присутствует индекс `filebeat-*`, статус `open` |
| 9 | Kibana | `http://<kibana_public_ip>:5601` | Index Pattern `filebeat-*` создан, видны записи access.log |
|10 | Filebeat | `sudo filebeat test output` | Соединение с Elasticsearch `OK` |
|11 | Snapshot | `yc compute snapshot-schedule get <schedule_id>` | Cron `0 3 * * *`, retention `7d` |
|12 | Документация | `docs/screenshots/*` | Скриншоты всех GUI сервисов приложены |
