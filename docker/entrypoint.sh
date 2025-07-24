#!/bin/bash

echo "⬇️ Завантажую свіжий import_employees.sh з GitHub..."
curl -s -o /docker-entrypoint-initdb.d/import_employees.sh \
     https://raw.githubusercontent.com/rifatismailov/study_sql/main/docker/import_employees.sh \
  && chmod +x /docker-entrypoint-initdb.d/import_employees.sh

# Запускаємо оригінальний entrypoint MySQL
exec docker-entrypoint.sh "$@"
