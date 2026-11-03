#!/usr/bin/env bash
set -euo pipefail

project='/mnt/c/Users/areyy/OneDrive/Documents/ChatGPT/Vendor-Purchase-Order-Portal'
secret_file='/home/areyy/.config/vendor-portal/.env'
network='vendor-purchase-order-portal_default'
selenium='portal-selenium'
cleanup() {
  if docker inspect "$selenium" >/dev/null 2>&1; then docker logs --tail 12 "$selenium" >&2 || true; fi
  docker rm -f "$selenium" >/dev/null 2>&1 || true
}
trap cleanup EXIT

cleanup
docker run -d --name "$selenium" --network "$network" --shm-size=2g \
  -e SE_NODE_MAX_SESSIONS=1 selenium/standalone-chrome:latest >/dev/null
ready=false
for _ in $(seq 1 60); do
  if docker run --rm --network "$network" curlimages/curl:8.12.1 \
      -fsS http://"$selenium":4444/status 2>/dev/null | grep -Eq '"ready"[[:space:]]*:[[:space:]]*true'; then
    ready=true
    break
  fi
  sleep 2
done
[[ "$ready" == true ]] || { echo 'Selenium browser did not become ready.' >&2; exit 1; }

it_selector=()
if [[ -n "${PORTAL_IT_METHOD:-}" ]]; then it_selector+=("-Dit.test=$PORTAL_IT_METHOD"); fi
docker run --rm --network "$network" --env-file "$secret_file" \
  -e E2E_USER=admin -e E2E_PASSWORD="$(sed -n 's/^ADMIN_PASSWORD=//p' "$secret_file")" \
  -e E2E_BASE_URL=http://frontend -e REMOTE_WEBDRIVER_URL="http://$selenium:4444/wd/hub" \
  -v "$project/backend:/workspace" -v /home/areyy/.m2:/root/.m2 -w /workspace \
  maven:3.9-eclipse-temurin-21 mvn -B -Pselenium "${it_selector[@]}" verify

docker run --rm --network "$network" --ipc=host --env-file "$secret_file" \
  -e BASE_URL=http://frontend -e E2E_USER=admin \
  -e E2E_PASSWORD="$(sed -n 's/^ADMIN_PASSWORD=//p' "$secret_file")" \
  -v "$project/frontend:/workspace" -w /workspace \
  mcr.microsoft.com/playwright:v1.64.1-noble \
  bash -lc 'npm ci --no-audit --no-fund && npm run test:e2e'

echo 'Selenium and Playwright integration checks passed.'
