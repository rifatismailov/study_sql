#!/bin/bash

set -e

REPO_NAME="test_db"
REPO_URL="https://github.com/datacharmer/test_db.git"
CONTAINER_NAME="mysql-db"
MYSQL_ROOT_PASSWORD="rootpass"
MYSQL_USER="test_user"
MYSQL_PASSWORD="Kh87Igs87HG"
MYSQL_DATABASE="employees"
WAIT_SECONDS=25

echo "🔽 Клоную базу даних..."
if [ ! -d "$REPO_NAME" ]; then
    git clone "$REPO_URL" "$REPO_NAME"
else
    echo "❗ $REPO_NAME вже існує, пропускаю клонування."
fi

cd "$REPO_NAME"

echo "🚀 Перевіряю чи контейнер запущений..."
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo "❗ Контейнер ще не запущено. Будь ласка, запусти його через docker-compose up -d"
    exit 1
fi

echo "⏳ Очікую $WAIT_SECONDS сек на повне завантаження MySQL..."
sleep $WAIT_SECONDS

echo "📂 Копіюю всі файли в контейнер..."
docker cp . "$CONTAINER_NAME":/var/lib/mysql-files/

echo "🛠 Оновлюю шляхи в employees.sql..."
docker exec "$CONTAINER_NAME" bash -c "
  sed -i 's|source \\(load_.*\\.dump\\)|source /var/lib/mysql-files/\\1|g' /var/lib/mysql-files/employees.sql &&
  sed -i 's|source show_elapsed.sql|source /var/lib/mysql-files/show_elapsed.sql|g' /var/lib/mysql-files/employees.sql
"

echo "🗃 Створюю базу $MYSQL_DATABASE (якщо ще не існує)..."
docker exec -i "$CONTAINER_NAME" mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE>

echo "🔑 Надаю повні привілеї користувачу $MYSQL_USER..."
docker exec -i "$CONTAINER_NAME" mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "
    CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
    GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
    GRANT RELOAD ON *.* TO '$MYSQL_USER'@'%';
    FLUSH PRIVILEGES;
"

echo "📥 Імпортую базу даних через $MYSQL_USER..."
docker exec -i "$CONTAINER_NAME" bash -c "
  mysql -u$MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE < /var/lib/mysql-files/employees.sql
"

echo "🔎 Перевіряю таблиці..."
docker exec -i "$CONTAINER_NAME" mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -e "USE $MYSQL_DATABASE; SHOW TABLES;"