FROM mysql:8.0

# Копіюємо entrypoint.sh з репозиторію
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Вказуємо кастомний entrypoint
ENTRYPOINT ["/entrypoint.sh"]
CMD ["mysqld"]
