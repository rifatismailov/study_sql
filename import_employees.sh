#!/bin/bash

set -e

# 🔧 Конфігурація
MYSQL_USER="test_user"
MYSQL_PASSWORD="Kh87Igs87HG"
MYSQL_DATABASE="employees"
WAIT_SECONDS=25
BASE_PATH="/var/lib/mysql-files/test_db"
REPO_API_URL="https://api.github.com/repos/datacharmer/test_db/contents"
RAW_URL="https://raw.githubusercontent.com/datacharmer/test_db/master"

echo "⏳ Очікування $WAIT_SECONDS секунд на запуск MySQL..."
sleep "$WAIT_SECONDS"

# 🗂 Створення базової директорії
echo "📁 Створюю директорію $BASE_PATH..."
mkdir -p "$BASE_PATH"

# 🔄 Рекурсивна функція завантаження
download_recursive() {
  local api_url="$1"
  local current_path="$2"

  echo "🌐 Отримую: $api_url"
  response=$(curl -s "$api_url")

  echo "$response" | jq -c '.[]' | while read -r item; do
    name=$(echo "$item" | jq -r '.name')
    type=$(echo "$item" | jq -r '.type')
    path=$(echo "$item" | jq -r '.path')

    if [[ "$type" == "file" ]]; then
      target_dir="$BASE_PATH/$current_path"

      # 🛡 Уникнення конфлікту з файлами
      if [[ -e "$target_dir" && ! -d "$target_dir" ]]; then
        echo "⚠️ Конфлікт: '$target_dir' — файл. Видаляю і створюю директорію..."
        rm -f "$target_dir"
      fi

      mkdir -p "$target_dir"
      echo "⬇️ Завантажую файл: $path"
      curl -s -o "$target_dir/$name" "$RAW_URL/$path"

    elif [[ "$type" == "dir" ]]; then
      echo "📁 Переходжу в директорію: $path"
      download_recursive "$REPO_API_URL/$path" "$path"
    fi
  done
}

# ▶️ Початок завантаження
download_recursive "$REPO_API_URL" ""

# 📍 Переходимо до каталогу
cd "$BASE_PATH"

# 🔧 Оновлення шляхів у employees.sql
if [[ -f "employees.sql" ]]; then
  echo "🛠 Оновлюю шляхи у employees.sql..."
  sed -i 's|source \(load_.*\.dump\)|source /var/lib/mysql-files/test_db/\1|g' employees.sql
  sed -i 's|source show_elapsed.sql|source /var/lib/mysql-files/test_db/show_elapsed.sql|g' employees.sql
else
  echo "❌ Не знайдено employees.sql"
  exit 1
fi

# 🛠 Створення бази
echo "🗃 Створюю базу $MYSQL_DATABASE..."
mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE"

# 🔑 Доступи для користувача
echo "🔑 Надаю доступ користувачу $MYSQL_USER..."
mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "
  CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
  GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
  GRANT RELOAD ON *.* TO '$MYSQL_USER'@'%';
  FLUSH PRIVILEGES;
"

# 📥 Імпорт бази employees
echo "📥 Імпортую базу $MYSQL_DATABASE..."
mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" < "$BASE_PATH/employees.sql" \
  && echo "✅ Імпорт employees успішний" || echo "❌ Помилка при імпорті"

echo "✅ Готово! Усі файли завантажено, база $MYSQL_DATABASE імпортована!"
