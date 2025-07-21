#!/bin/bash

set -e

MYSQL_USER="test_user"
MYSQL_PASSWORD="Kh87Igs87HG"
MYSQL_DATABASE="employees"
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

echo "🛠 Оновлюю шляхи у employees.sql..."
sed -i 's|source \(load_.*\.dump\)|source /var/lib/mysql-files/test_db/\1|g' employees.sql
sed -i 's|source show_elapsed.sql|source /var/lib/mysql-files/test_db/show_elapsed.sql|g' employees.sql

echo "🗃 Створюю базу $MYSQL_DATABASE..."
mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE"

echo "🔑 Надаю доступ користувачу $MYSQL_USER..."
mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "
  CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
  GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
  GRANT RELOAD ON *.* TO '$MYSQL_USER'@'%';
  FLUSH PRIVILEGES;
"

echo "📥 Імпортую базу..."
mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" < employees.sql

echo "✅ Готово!"
