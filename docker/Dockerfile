FROM mysql:8.0

# Копіюємо скрипт
RUN curl -o /docker-entrypoint-initdb.d/import_employees.sh https://raw.githubusercontent.com/rifatismailov/study_sql/main/docker/import_employees.sh \
 && chmod +x /docker-entrypoint-initdb.d/import_employees.sh
