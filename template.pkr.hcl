packer {
  required_plugins {
    digitalocean = {
      version = ">= 1.0.4"
      source  = "github.com/digitalocean/digitalocean"
    }
  }
}

variable "do_token" {
  type        = string
  description = "DigitalOcean access token"
  sensitive   = true
}

variable "vm_region" {
  type        = string
  description = "DigitalOcean region"
  default     = "ams3"
}

variable "vm_size" {
  type        = string
  description = "DigitalOcean image default size"
  default     = "s-1vcpu-1gb"
}

variable "vm_image_name" {
  type        = string
  description = "DigitalOcean image name"
  default     = "ubuntu-22-04-x64"
}

variable "username" {
  type        = string
  description = "Ansible username"
  default     = "ansible"
}

variable "password" {
  type        = string
  description = "Ansible password"
  default     = "root"
  sensitive   = true
}

variable "public_key" {
  type        = string
  description = "Authorize public key"
  sensitive   = true
}

source "digitalocean" "vm" {
  api_token          = var.do_token
  image              = var.vm_image_name
  region             = var.vm_region
  size               = var.vm_size
  ssh_username       = "root"
  private_networking = true

  snapshot_name = "ubuntu-22.04-${formatdate("DD-MM-YYYY", timestamp())}"

  tags = ["ansible"]
}

build {
  sources = ["source.digitalocean.vm"]

  provisioner "shell" {
    script           = "script.sh"
    environment_vars = [
      "USERNAME=${var.username}",
      "PASSWORD=${var.password}",
      "PUBLIC_KEY=${var.public_key}",
    ]
  }
}