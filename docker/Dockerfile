FROM mysql:8.0

RUN curl -o /docker-entrypoint-initdb.d/import_employees.sh https://raw.githubusercontent.com/rifatismailov/study_sql/main/import_employees.sh \
 && chmod +x /docker-entrypoint-initdb.d/import_employees.sh

RUN curl -o /docker-entrypoint-initdb.d/import_sakila.sh https://raw.githubusercontent.com/rifatismailov/study_sql/main/import_sakila.sh \
 && chmod +x /docker-entrypoint-initdb.d/import_sakila.sh
