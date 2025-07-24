FROM mysql:8.0

# Download entrypoint.sh from GitHub and make it executable
RUN curl -s -o /entrypoint.sh https://raw.githubusercontent.com/rifatismailov/study_sql/main/docker/entrypoint.sh \
    && chmod +x /entrypoint.sh

# Use the downloaded entrypoint.sh as the entrypoint
ENTRYPOINT ["/entrypoint.sh"]
CMD ["mysqld"]
