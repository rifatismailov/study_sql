#!/bin/bash

set -e

MYSQL_USER="test_user"
MYSQL_PASSWORD="Kh87Igs87HG"
EMPLOYEES_DB="employees"
SAKILA_DB="sakila"
WAIT_SECONDS=25
BASE_PATH="/var/lib/mysql-files/test_db"
RAW_URL="https://raw.githubusercontent.com/datacharmer/test_db/master"

echo "⏳ Очікування $WAIT_SECONDS секунд на запуск MySQL..."
sleep $WAIT_SECONDS

echo "📁 Створюю директорію $BASE_PATH..."
mkdir -p "$BASE_PATH"
cd "$BASE_PATH"

echo "🌐 Отримую список файлів з GitHub..."
LIST_URL="https://api.github.com/repos/datacharmer/test_db/contents"
FILE_LIST=$(curl -s "$LIST_URL" | grep '"name":' | cut -d '"' -f 4)

echo "🔽 Завантажую файли..."
for FILE in $FILE_LIST; do
  echo "→ $FILE"
  curl -s -O "$RAW_URL/$FILE"
done

SAKILA_PATH="$BASE_PATH/sakila"
cd "$BASE_PATH"

echo "🛠 Оновлюю шляхи у employees.sql..."
sed -i 's|source \(load_.*\.dump\)|source /var/lib/mysql-files/test_db/\1|g' employees.sql
sed -i 's|source show_elapsed.sql|source /var/lib/mysql-files/test_db/show_elapsed.sql|g' employees.sql

echo "🗃 Створюю бази $EMPLOYEES_DB і $SAKILA_DB..."
mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS $EMPLOYEES_DB"
mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS $SAKILA_DB"

echo "🔑 Надаю доступ користувачу $MYSQL_USER..."
mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "
  CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
  GRANT ALL PRIVILEGES ON $EMPLOYEES_DB.* TO '$MYSQL_USER'@'%';
  GRANT ALL PRIVILEGES ON $SAKILA_DB.* TO '$MYSQL_USER'@'%';
  GRANT RELOAD ON *.* TO '$MYSQL_USER'@'%';
  FLUSH PRIVILEGES;
"

echo "📥 Імпортую базу $EMPLOYEES_DB..."
mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$EMPLOYEES_DB" < employees.sql

echo "📥 Імпортую базу $SAKILA_DB..."
mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$SAKILA_DB" < "$SAKILA_PATH/sakila-mv-schema.sql"
mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$SAKILA_DB" < "$SAKILA_PATH/sakila-mv-data.sql"

echo "✅ Успішно встановлено бази employees та sakila!"
