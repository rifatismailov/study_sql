#!/bin/bash

echo "⬇️ Downloading the latest import_employees.sh from GitHub..."
curl -s -o /docker-entrypoint-initdb.d/import_employees.sh \
    https://raw.githubusercontent.com/rifatismailov/study_sql/main/docker/import_employees.sh \
    && chmod +x /docker-entrypoint-initdb.d/import_employees.sh

# Start MySQL
exec docker-entrypoint.sh "$@"
