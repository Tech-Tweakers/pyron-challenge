#!/bin/bash
set -xe

# Variables set by Terraform via templatefile interpolation:
# ${git_repo} ${git_branch} ${swarm_user}

# create deploy user if not exists
id -u ${swarm_user} &>/dev/null || useradd -m -s /bin/bash ${swarm_user}

# update and install prerequisites
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release git

# install docker (official)
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  > /etc/apt/sources.list.d/docker.list

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

# install docker compose plugin (v2)
mkdir -p /usr/libexec/docker
apt-get install -y jq
DOCKER_COMPOSE_VERSION="v2.17.3" # pinned, change if desired
curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# allow deploy user to use docker
usermod -aG docker ${swarm_user}

# create folder for app
APP_DIR="/home/${swarm_user}/app"
rm -rf ${APP_DIR}
mkdir -p ${APP_DIR}
chown ${swarm_user}:${swarm_user} ${APP_DIR}

# clone repo (or re-clone)
if [ -n "${git_repo}" ]; then
  sudo -u ${swarm_user} git clone --branch ${git_branch} ${git_repo} ${APP_DIR} || {
    # if already exists, try pull
    cd ${APP_DIR}
    sudo -u ${swarm_user} git pull origin ${git_branch} || true
  }
fi

# optional: create .env from template (you must later edit with secrets)
cat > ${APP_DIR}/.env <<'EOF'
USE_SSL=false
REDIS_HOST=redis
REDIS_PORT=6379
MONGO_URI=mongodb://mongo:27017
MONGO_DB=pyron
EOF
chown ${swarm_user}:${swarm_user} ${APP_DIR}/.env
chmod 600 ${APP_DIR}/.env

# run docker compose (assumes docker-compose.yml at repo root)
cd ${APP_DIR}
sudo -u ${swarm_user} /usr/local/bin/docker-compose pull || true
sudo -u ${swarm_user} /usr/local/bin/docker-compose up -d --build

# enable docker service and restart once
systemctl enable docker
systemctl restart docker
