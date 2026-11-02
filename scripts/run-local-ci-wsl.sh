#!/usr/bin/env bash
set -euo pipefail

project='/mnt/c/Users/areyy/OneDrive/Documents/ChatGPT/Vendor-Purchase-Order-Portal'
source_repo='/home/areyy/.cache/vendor-portal-ci/source'
work_root='/home/areyy/.cache/vendor-portal-ci'
secret_file='/home/areyy/.config/vendor-portal/.env'
jenkins_container='vendor-portal-jenkins'
registry_container='vendor-portal-registry'
jenkins_image='vendor-portal-jenkins:local'
jenkins_home="$work_root/jenkins-clean"

[[ -f "$secret_file" ]] || { echo 'Portal secret file is missing; run scripts/run-integration.ps1 first.' >&2; exit 1; }
if ! grep -q '^JENKINS_ADMIN_PASSWORD=' "$secret_file"; then
  printf 'JENKINS_ADMIN_USER=admin\nJENKINS_ADMIN_PASSWORD=%s\n' "$(openssl rand -base64 36 | tr -d '\n')" >> "$secret_file"
fi
chmod 600 "$secret_file"

mkdir -p "$work_root"
if ! git config --global --get-all safe.directory | grep -Fxq "$project/.git"; then
  git config --global --add safe.directory "$project/.git"
fi
if ! git config --global --get-all safe.directory | grep -Fxq "$source_repo"; then
  git config --global --add safe.directory "$source_repo"
fi
if [[ ! -e "$source_repo/.git" ]]; then
  git clone --no-local "$project" "$source_repo"
fi
git -C "$source_repo" fetch --all --prune
git -C "$source_repo" checkout develop
git -C "$source_repo" reset --hard origin/develop 2>/dev/null || git -C "$source_repo" reset --hard develop
chown -R 1000:1000 "$work_root"
mkdir -p "$jenkins_home"
chown -R 1000:1000 "$jenkins_home"
mkdir -p "$jenkins_home/init.groovy.d"
cp "$source_repo/ci/jenkins/init.groovy.d/create-job.groovy" "$jenkins_home/init.groovy.d/create-job.groovy"
chown 1000:1000 "$jenkins_home/init.groovy.d/create-job.groovy"

compose_cli='/usr/libexec/docker/cli-plugins/docker-compose'
[[ -x "$compose_cli" ]] || { echo 'The host Docker Compose plugin was not found.' >&2; exit 1; }
cp "$compose_cli" "$source_repo/ci/jenkins/docker-compose"
docker build -f "$source_repo/ci/jenkins/Dockerfile" -t "$jenkins_image" "$source_repo/ci/jenkins"
rm -f "$source_repo/ci/jenkins/docker-compose"
docker rm -f "$jenkins_container" "$registry_container" >/dev/null 2>&1 || true
docker run -d --name "$registry_container" --restart unless-stopped --network host \
  -e REGISTRY_HTTP_ADDR=127.0.0.1:5000 \
  -v vendor-portal-registry-data:/var/lib/registry registry:2 >/dev/null

socket_gid=$(stat -c '%g' /var/run/docker.sock)
docker run -d --name "$jenkins_container" --restart unless-stopped --network host \
  --group-add "$socket_gid" \
  -e JENKINS_OPTS='--httpPort=8081 --httpListenAddress=127.0.0.1' \
  -e JAVA_OPTS='-Dhudson.plugins.git.GitSCM.ALLOW_LOCAL_CHECKOUT=true' \
  -e CASC_JENKINS_CONFIG=/usr/share/jenkins/ref/casc.yaml \
  -e JENKINS_HOME="$jenkins_home" \
  -e PUBLISH_IMAGES=true -e REGISTRY_HOST=localhost:5000 -e REGISTRY_NAMESPACE=vendor \
  --env-file "$secret_file" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$work_root:$work_root" \
  "$jenkins_image" >/dev/null

for _ in $(seq 1 120); do
  if curl -fsS http://127.0.0.1:8081/login >/dev/null; then break; fi
  sleep 5
done
jenkins_admin_password=$(sed -n 's/^JENKINS_ADMIN_PASSWORD=//p' "$secret_file")
netrc=$(mktemp)
headers=$(mktemp)
cookies=$(mktemp)
trap 'rm -f "$netrc" "$headers" "$cookies"' EXIT
printf 'machine 127.0.0.1 login admin password %s\n' "$jenkins_admin_password" > "$netrc"
chmod 600 "$netrc"
base='http://127.0.0.1:8081'
curl -fsS --netrc-file "$netrc" "$base/api/json" >/dev/null
curl -fsS http://127.0.0.1:5000/v2/ >/dev/null
crumb_json=$(curl -fsS --netrc-file "$netrc" -c "$cookies" "$base/crumbIssuer/api/json")
crumb_header=$(python3 -c 'import json,sys; d=json.load(sys.stdin); print(d["crumbRequestField"]+": "+d["crumb"])' <<< "$crumb_json")
curl -fsS --netrc-file "$netrc" -b "$cookies" -c "$cookies" -X POST -H "$crumb_header" -D "$headers" \
  --data-urlencode 'PUBLISH_IMAGES=true' \
  --data-urlencode 'REGISTRY_HOST=localhost:5000' \
  --data-urlencode 'REGISTRY_NAMESPACE=vendor' \
  "$base/job/vendor-portal-ci/buildWithParameters" -o /dev/null
queue_location=$(awk 'tolower($1)=="location:" {gsub("\r", "", $2); print $2}' "$headers")
queue_id=$(sed -n 's#.*queue/item/\([0-9][0-9]*\)/.*#\1#p' <<< "$queue_location")
[[ -n "$queue_id" ]] || { echo 'Jenkins did not return a queue item for the pipeline.' >&2; exit 1; }

build_number=''
for _ in $(seq 1 180); do
  queue_json=$(curl -fsS --netrc-file "$netrc" "$base/queue/item/$queue_id/api/json")
  build_number=$(python3 -c 'import json,sys; print(json.load(sys.stdin).get("executable",{}).get("number", ""))' <<< "$queue_json")
  [[ -n "$build_number" ]] && break
  sleep 5
done
[[ -n "$build_number" ]] || { echo 'Jenkins pipeline stayed queued for 15 minutes.' >&2; exit 1; }

build_result=''
for _ in $(seq 1 180); do
  build_json=$(curl -fsS --netrc-file "$netrc" "$base/job/vendor-portal-ci/$build_number/api/json")
  build_state=$(python3 -c 'import json,sys; d=json.load(sys.stdin); print(str(d.get("building", True)).lower()+" "+str(d.get("result") or ""))' <<< "$build_json")
  read -r is_building build_result <<< "$build_state"
  [[ "$is_building" == false ]] && break
  sleep 5
done
curl -fsS --netrc-file "$netrc" "$base/job/vendor-portal-ci/$build_number/consoleText" | tail -n 100
[[ "$build_result" == SUCCESS ]] || { echo "Jenkins build $build_number result: ${build_result:-TIMED OUT}" >&2; exit 1; }
echo "Jenkins build $build_number result: $build_result"

echo 'Local Jenkins is ready at http://localhost:8081; local registry is at localhost:5000.'
echo 'Job: vendor-portal-ci (pipeline from the local develop branch).'
