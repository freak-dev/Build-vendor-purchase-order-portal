#!/usr/bin/env bash
set -euo pipefail

# Run inside Ubuntu WSL as root. Docker's official apt repository supports Ubuntu 26.04.
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
arch="$(dpkg --print-architecture)"
codename="$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")"
cat > /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: ${codename}
Components: stable
Architectures: ${arch}
Signed-By: /etc/apt/keyrings/docker.asc
EOF
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin ansible-core
systemctl enable --now docker
usermod -aG docker areyy
runuser -u areyy -- env ANSIBLE_HOME=/home/areyy/.ansible ansible-galaxy collection install community.docker:5.4.0
printf '\nInstalled tools:\n'
docker --version
docker compose version
ansible --version | head -n 2
