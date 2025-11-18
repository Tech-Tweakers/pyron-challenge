resource "digitalocean_droplet" "app" {
  name   = var.droplet_name
  region = var.region
  size   = var.size
  image  = "ubuntu-22-04-x64"

  ssh_keys = var.ssh_fingerprint != "" ? [var.ssh_fingerprint] : []

  user_data = templatefile("${path.module}/cloud-init.sh", {
    GIT_REPO               = var.git_repo
    GIT_BRANCH             = var.git_branch
    SWARM_USER             = var.swarm_user
    DOCKER_COMPOSE_VERSION = var.docker_compose_version
  })
}

resource "digitalocean_floating_ip" "app_ip" {
  region = var.region
}

resource "digitalocean_floating_ip_assignment" "app_assign" {
  ip_address = digitalocean_floating_ip.app_ip.ip_address
  droplet_id = digitalocean_droplet.app.id
}
