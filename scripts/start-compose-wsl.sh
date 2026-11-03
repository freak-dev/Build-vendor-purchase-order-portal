#!/usr/bin/env bash
set -euo pipefail

project='/mnt/c/Users/areyy/OneDrive/Documents/ChatGPT/Vendor-Purchase-Order-Portal'
secret_dir='/home/areyy/.config/vendor-portal'
secret_file="$secret_dir/.env"
install -d -m 0700 -o areyy -g areyy "$secret_dir"
if [[ ! -f "$secret_file" ]]; then
  umask 077
  printf 'DB_PASSWORD=%s\nMYSQL_ROOT_PASSWORD=%s\nADMIN_USERNAME=admin\nADMIN_PASSWORD=%s\nHTTP_PORT=8088\n' \
    "$PORTAL_DB_PASSWORD" "$PORTAL_MYSQL_ROOT_PASSWORD" "$PORTAL_ADMIN_PASSWORD" > "$secret_file"
  chown areyy:areyy "$secret_file"
  chmod 0600 "$secret_file"
fi
docker compose --env-file "$secret_file" \
  -f "$project/docker-compose.yml" \
  --project-directory "$project" up --build -d --wait --wait-timeout 300
