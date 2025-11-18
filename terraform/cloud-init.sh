#!/bin/bash
set -e

GIT_REPO="${GIT_REPO}"
GIT_BRANCH="${GIT_BRANCH}"
SWARM_USER="${SWARM_USER}"
DOCKER_COMPOSE_VERSION="${DOCKER_COMPOSE_VERSION}"

# Create user
useradd -m -s /bin/bash "${SWARM_USER}"
usermod -aG sudo "${SWARM_USER}"

# Update system
apt-get update -y
apt-get upgrade -y

# Install Docker
apt-get install -y ca-certificates curl gnupg lsb-release

mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" \
  > /etc/apt/sources.list.d/docker.list

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin

# Docker Compose
curl -SL "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-linux-x86_64" \
  -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Allow user docker access
usermod -aG docker "${SWARM_USER}"

# Clone and deploy
sudo -u "${SWARM_USER}" bash <<EOF
cd /home/${SWARM_USER}
git clone --branch ${GIT_BRANCH} ${GIT_REPO} app
cd app
touch .env
docker-compose up -d --build
EOF
