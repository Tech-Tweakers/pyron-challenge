locals {
  project_name = var.project
}

resource "digitalocean_vpc" "pyron_vpc" {
  name   = "${local.project_name}-vpc"
  region = var.region
  description = "VPC for PyRon challenge"
}

resource "digitalocean_droplet" "app" {
  name   = var.droplet_name
  region = var.region
  size   = var.droplet_size
  image  = var.image
  vpc_uuid = digitalocean_vpc.pyron_vpc.id

  # optional ssh
  dynamic "ssh_keys" {
    for_each = var.ssh_fingerprint != "" ? [var.ssh_fingerprint] : []
    content {
      fingerprint = ssh_keys.value
    }
  }

  user_data = templatefile("${path.module}/cloud-init.sh", {
    git_repo   = var.git_repo
    git_branch = var.git_branch
    swarm_user = var.swarm_user
  })

  tags = [local.project_name]
}

# Floating IP to give static public IP
resource "digitalocean_floating_ip" "ip" {
  region = var.region
  depends_on = [digitalocean_droplet.app]
}

# Assign floating ip to droplet
resource "digitalocean_floating_ip_assignment" "assignment" {
  floating_ip = digitalocean_floating_ip.ip.ip_address
  droplet_id  = digitalocean_droplet.app.id
}

# Basic firewall allowing SSH, HTTP(S) and Docker required ports
resource "digitalocean_firewall" "fw" {
  name = "${local.project_name}-fw"
  droplet_ids = [digitalocean_droplet.app.id]

  inbound_rule {
    protocol = "tcp"
    port_range = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol = "tcp"
    port_range = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol = "tcp"
    port_range = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol = "tcp"
    port_range = "3000-9000" # optional range for debugging/alternate ports
    source_addresses = ["127.0.0.1/32"]
  }

  outbound_rule {
    protocol = "tcp"
    port_range = "all"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

# (Optional) Project record - groups resources
resource "digitalocean_project" "project" {
  name        = local.project_name
  purpose     = "Webhooks challenge"
  environment = "development"
}
