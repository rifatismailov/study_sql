FROM mysql:8.0

ARG CACHE_BUSTER=force

RUN echo "Cache bust: $CACHE_BUSTER" \
 && curl -s -o /docker-entrypoint-initdb.d/import_employees.sh \
      https://raw.githubusercontent.com/rifatismailov/study_sql/main/docker/import_employees.sh \
 && chmod +x /docker-entrypoint-initdb.d/import_employees.sh
