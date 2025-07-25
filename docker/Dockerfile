FROM mysql:8.0

# Завантаження скриптів через правильні RAW-посилання
RUN curl -s -f -o /docker-entrypoint-initdb.d/import_employees.sh \
    https://raw.githubusercontent.com/rifatismailov/study_sql/main/docker/import_employees.sh \
 && chmod +x /docker-entrypoint-initdb.d/import_employees.sh

RUN curl -s -f -o /docker-entrypoint-initdb.d/import_sakila.sh \
    https://raw.githubusercontent.com/rifatismailov/study_sql/main/docker/import_sakila.sh \
 && chmod +x /docker-entrypoint-initdb.d/import_sakila.sh
