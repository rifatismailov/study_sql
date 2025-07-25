#!/bin/bash

set -e

# 🔧 Конфігурація
MYSQL_USER="test_user"
MYSQL_PASSWORD="Kh87Igs87HG"
MYSQL_DATABASE="sakila"
MYSQL_ROOT_PASSWORD="rootpass"
WAIT_SECONDS=5
BASE_PATH="/var/lib/mysql-files/sakila"
RAW_URL="https://raw.githubusercontent.com/datacharmer/test_db/master/sakila"

echo "⏳ Очікування $WAIT_SECONDS секунд..."
sleep "$WAIT_SECONDS"

# 📁 Створюємо директорію
echo "📁 Створюю директорію $BASE_PATH..."
mkdir -p "$BASE_PATH"

# 📥 Список файлів для завантаження
FILES=(
  "sakila-mv-schema.sql"
  "sakila-mv-data.sql"
)

# ⬇️ Завантаження файлів
for file in "${FILES[@]}"; do
  echo "⬇️ Завантажую $file → $BASE_PATH/$file"
  curl -s -o "$BASE_PATH/$file" "$RAW_URL/$file"
done

# ⚙️ Увімкнення дозволу на створення функцій
echo "⚙️ Встановлюю log_bin_trust_function_creators = 1..."
mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "SET GLOBAL log_bin_trust_function_creators = 1;"

# 🛠 Створення бази
echo "🗃 Створюю базу $MYSQL_DATABASE..."
mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE"

# 🔑 Надаємо доступи користувачу
echo "🔑 Надаю доступ користувачу $MYSQL_USER..."
mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "
  GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
  FLUSH PRIVILEGES;
"

# 📥 Імпортуємо схему
echo "📥 Імпортую схему..."
mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" < "$BASE_PATH/sakila-mv-schema.sql"

# 📥 Імпортуємо дані
echo "📥 Імпортую дані..."
mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" < "$BASE_PATH/sakila-mv-data.sql"

echo "✅ Готово! База $MYSQL_DATABASE створена і заповнена!"
