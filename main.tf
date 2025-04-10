terraform {
  backend "s3" {
    endpoints                   = { s3 = "https://nyc3.digitaloceanspaces.com" }
    region                      = "us-east-1"
    bucket                      = "leetops-terraform-study"
    key                         = "terraform.tfstate"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    encrypt                     = true
  }

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
}
variable "pvt_key" {
  description = "Private SSH Key path"
  type        = string
}
variable "pub_key" {
  description = "Public SSH Key path"
  type        = string
}

provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_ssh_key" "terraform-deploy" {
  name = "terraform-deploy"
}

resource "digitalocean_domain" "sysraccoon" {
  name       = "sysraccoon.xyz"
  ip_address = digitalocean_droplet.www.ipv4_address
}

resource "digitalocean_record" "www" {
  domain = digitalocean_domain.sysraccoon.id
  type   = "A"
  name   = "www"
  value  = digitalocean_droplet.www.ipv4_address
}

resource "digitalocean_droplet" "www" {
  image  = "ubuntu-20-04-x64"
  name   = "www"
  region = "nyc3"
  size   = "s-1vcpu-1gb"
  ssh_keys = [
    data.digitalocean_ssh_key.terraform-deploy.id
  ]

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install python3 -y",
    ]

    connection {
      host        = self.ipv4_address
      type        = "ssh"
      user        = "root"
      private_key = file(var.pvt_key)
    }
  }

  # provisioner "local-exec" {
  #   command = <<-EOT
  #     mkdir -p ${path.module}/.ssh
  #     ssh-keyscan -H ${digitalocean_droplet.www.ipv4_address} > ${path.module}/.ssh/known_hosts
  #     ANSIBLE_SSH_ARGS='-o UserKnownHostsFile=${path.module}/.ssh/known_hosts -o IdentitiesOnly=yes -i ${var.pvt_key}' \
  #     ./ansible/setup_server.sh root ${self.ipv4_address} ${var.pvt_key} ${var.pub_key}
  #   EOT
  # }
}

