output "droplet_id" {
  value = digitalocean_droplet.app.id
}

output "droplet_public_ip" {
  value = digitalocean_floating_ip.ip.ip_address
}

output "droplet_private_ipv4" {
  value = digitalocean_droplet.app.ipv4_address_private
}

output "ssh_instructions" {
  value = "ssh root@${digitalocean_floating_ip.ip.ip_address}  (or use the user you configured)"
}
