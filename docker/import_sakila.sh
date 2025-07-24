#!/bin/bash

set -e

# 🔧 Налаштування
MYSQL_USER="test_user"
MYSQL_PASSWORD="Kh87Igs87HG"
MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-rootpass}"
SAKILA_DB="sakila"
SAKILA_PATH="/var/lib/mysql-files/test_db/sakila"

# 🔍 Перевірка наявності файлів
if [[ ! -f "$SAKILA_PATH/sakila-mv-schema.sql" ]] || [[ ! -f "$SAKILA_PATH/sakila-mv-data.sql" ]]; then
  echo "❌ Не знайдено файлів sakila-mv-schema.sql або sakila-mv-data.sql у $SAKILA_PATH"
  exit 1
fi

echo "🗃 Створюю базу даних $SAKILA_DB..."
mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "DROP DATABASE IF EXISTS $SAKILA_DB; CREATE DATABASE $SAKILA_DB;"

echo "🔑 Надаю доступ користувачу $MYSQL_USER..."
mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "
  CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
  GRANT ALL PRIVILEGES ON $SAKILA_DB.* TO '$MYSQL_USER'@'%';
  FLUSH PRIVILEGES;
"

echo "📥 Імпортую схему sakila..."
mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$SAKILA_DB" < "$SAKILA_PATH/sakila-mv-schema.sql" \
  && echo "✅ Імпорт schema успішний" || echo "❌ Помилка при імпорті schema"

echo "📥 Імпортую дані sakila..."
mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$SAKILA_DB" < "$SAKILA_PATH/sakila-mv-data.sql" \
  && echo "✅ Імпорт даних успішний" || echo "❌ Помилка при імпорті data"

echo "🏁 База $SAKILA_DB готова до використання!"
