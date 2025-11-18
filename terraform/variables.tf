variable "do_token" {
  type        = string
  description = "DigitalOcean API token"
  sensitive   = true
}

variable "git_repo" {
  type        = string
  description = "Repository URL to clone on deployment"
}

variable "git_branch" {
  type        = string
  description = "Branch to clone on deployment"
  default     = "main"
}

variable "ssh_fingerprint" {
  type        = string
  description = "SSH key fingerprint (optional)"
  default     = ""
}

variable "droplet_name" {
  type        = string
  description = "Droplet name"
  default     = "pyron-app"
}

variable "region" {
  type        = string
  description = "DigitalOcean region"
  default     = "nyc3"
}

variable "size" {
  type        = string
  description = "Droplet size"
  default     = "s-1vcpu-2gb"
}

variable "docker_compose_version" {
  type        = string
  description = "Docker Compose plugin version"
  default     = "v2.17.3"
}

variable "swarm_user" {
  type        = string
  description = "User created on droplet"
  default     = "deploy"
}
