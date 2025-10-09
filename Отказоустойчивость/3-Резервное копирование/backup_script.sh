#!/bin/bash

# Скрипт резервного копирования домашней директории
# Автор: Бахаев Андрей
# Дата создания: 2025-10-09

# Переменные
DATE=$(date '+%Y-%m-%d %H:%M:%S')
SOURCE="$HOME/homework3/user_home"
DEST="$HOME/homework3/backup"
LOG_FILE="$HOME/homework3/backup.log"

# Создание директории для резервных копий, если не существует
mkdir -p "$DEST"

# Выполнение rsync
rsync -av --delete --exclude='.*' "$SOURCE/" "$DEST/" >> /tmp/rsync_output.log 2>&1

# Проверка результата выполнения
if [ $? -eq 0 ]; then
    echo "[$DATE] SUCCESS: Резервное копирование выполнено успешно" | tee -a "$LOG_FILE"
    logger -t backup_script "Резервное копирование выполнено успешно"
else
    echo "[$DATE] ERROR: Ошибка при выполнении резервного копирования" | tee -a "$LOG_FILE"
    logger -t backup_script "Ошибка при выполнении резервного копирования"
    exit 1
fi

# Вывод статистики
BACKUP_SIZE=$(du -sh "$DEST" | cut -f1)
echo "[$DATE] INFO: Размер резервной копии: $BACKUP_SIZE" | tee -a "$LOG_FILE"
