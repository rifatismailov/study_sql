#!/bin/bash
set -euo pipefail

MYSQL_USER="test_user"
MYSQL_PASSWORD="Kh87Igs87HG"
MYSQL_DATABASE="employees"
WAIT_SECONDS=25
BASE_PATH="/var/lib/mysql-files/test_db"
REPO_API_URL="https://api.github.com/repos/datacharmer/test_db/contents"
RAW_URL="https://raw.githubusercontent.com/datacharmer/test_db/master"

echo "⏳ Очікування $WAIT_SECONDS секунд на запуск MySQL..."
sleep "$WAIT_SECONDS"

echo "📁 Створюю директорію $BASE_PATH..."
mkdir -p "$BASE_PATH"

# Якщо колись випадково створився файл 'sakila' — зносимо його
if [[ -e "$BASE_PATH/sakila" && ! -d "$BASE_PATH/sakila" ]]; then
  echo "⚠️ Знайшов файл $BASE_PATH/sakila. Видаляю, щоб створити папку..."
  rm -f "$BASE_PATH/sakila"
fi
лжойшгц оугйцпу нйцу цуйц уй цу23312
download_recursive() {
  local api_url="$1"
  local current_path="$2"   # відносний шлях усередині BASE_PATH (може бути "")

  echo "🌐 Отримуцю: $api_uівівrl"
  local response
  response=$(curl -s "$api_url")

  echo "$response" | jq -c '.[]' | while read -r item; do
    local name type path
    name=$(echo "$item" | jq -r '.name')
    type=$(echo "$item" | jq -r '.type')
    path=$(echo "$item" | jq -r '.path')

    local target_dir="$BASE_PATH${current_path:+/$current_path}"

    if [[ "$type" == "file" ]]; then
      # Якщо target_dir існує як файл — прибираємо
      if [[ -e "$target_dir" && ! -d "$target_dir" ]]; then
        echo "⚠️ Конфлікт: '$target_dir' — файл. Видаляю..."
        rm -f "$target_dir"
      fi

      mkdir -p "$target_dir"
      echo "⬇️ Завантажую файл: $path"
      curl -s -o "$target_dir/$name" "$RAW_URL/$path"

    elif [[ "$type" == "dir" ]]; then
      echo "📁 Папка: $path"
      # Рекурсія з оновленим current_path
      local next_path
      if [[ -z "$current_path" ]]; then
        next_path="$name"
      else
        next_path="$current_path/$name"
      fi
      download_recursive "$REPO_API_URL/$path" "$next_path"
    fi
  done
}

download_recursive "$REPO_API_URL" ""

cd "$BASE_PATH"

if [[ -f "employees.sql" ]]; then
  echo "🛠 Патчу paths в employees.sql..."
  sed -i 's|source \(load_.*\.dump\)|source /var/lib/mysql-files/test_db/\1|g' employees.sql
  sed -i 's|source show_elapsed.sql|source /var/lib/mysql-files/test_db/show_elapsed.sql|g' employees.sql
else
  echo "❌ Не знайдено employees.sql"
  exit 1
fi

echo "🗃 Створюю базу $MYSQL_DATABASE..."
mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE"

echo "🔑 Надаю доступ користувачу $MYSQL_USER..."
mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "
  CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
  GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
  GRANT RELOAD ON *.* TO '$MYSQL_USER'@'%';
  FLUSH PRIVILEGES;
"

echo "📥 Імпортую $MYSQL_DATABASE..."
mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" < "$BASE_PATH/employees.sql" \
  && echo "✅ Імпорт employees успішний" || echo "❌ Помилка при імпорті"

echo "✅ Готово!"
