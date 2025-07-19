FROM mysql:8.0

# Копіюємо скрипт із GitHub
RUN curl -o /import_employees.sh https://raw.githubusercontent.com/rifatismailov/study_sql/main/import_employees.sh && \
    chmod +x /import_employees.sh

# Додаємо команду запуску скрипта після старту MySQL
CMD ["sh", "-c", "/entrypoint.sh mysqld & sleep 30 && /import_employees.sh && tail -f /dev/null"]
