terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.19"
    }
  }
  required_version = ">= 1.2.0"
}

provider "digitalocean" {
  token = var.do_token
}
