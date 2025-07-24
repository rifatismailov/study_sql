FROM mysql:8.0

# Копіюємо кастомний entrypoint
COPY ./docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/docker/entrypoint.sh"]
CMD ["mysqld"]
