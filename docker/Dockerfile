FROM mysql:8.0

# Встановлюємо git, curl, bash
RUN apt-get update && apt-get install -y curl bash git

# Копіюємо скрипт
RUN curl -o /docker-entrypoint-initdb.d/import_employees.sh https://raw.githubusercontent.com/rifatismailov/study_sql/main/import_employees.sh \
 && chmod +x /docker-entrypoint-initdb.d/import_employees.sh
