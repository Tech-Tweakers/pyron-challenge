variable "do_token" {
  description = "DigitalOcean API token (set via TF_VAR_do_token or -var)"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "Region for Droplet (e.g. nyc1, sfo3, fra1, ams3)"
  type        = string
  default     = "nyc1"
}

variable "droplet_name" {
  type    = string
  default = "pyron-app-1"
}

variable "droplet_size" {
  description = "Droplet size slug"
  type        = string
  default     = "s-2vcpu-4gb"
}

variable "image" {
  description = "Droplet image"
  type        = string
  default     = "ubuntu-22-04-x64"
}

variable "ssh_fingerprint" {
  description = "SSH key fingerprint registered in DigitalOcean (optional). If provided, key will be added to droplet."
  type        = string
  default     = ""
}

variable "project" {
  description = "Optional project name"
  type        = string
  default     = "pyron-project"
}

variable "git_repo" {
  description = "Git repository URL to clone and deploy (expects docker-compose.yml at repo root)."
  type        = string
  default     = ""
}

variable "git_branch" {
  description = "Branch to checkout"
  type        = string
  default     = "main"
}

variable "swarm_user" {
  description = "User to run deployment (cloud-init creates this user)"
  type        = string
  default     = "do-user"
}
