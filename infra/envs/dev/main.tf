terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.124.0"
    }
  }
}

provider "proxmox" {}

data "proxmox_file" "ubuntu" {
  node_name    = "pve"
  datastore_id = "local"
  content_type = "import"
  file_name    = "ubuntu-24.04-server-cloudimg-amd64.img.raw"
}

output "ubuntu_image_id" {
  value = data.proxmox_file.ubuntu.id
}
module "network" {
  source        = "../../modules/network"
  node_name     = "pve"
  public_bridge = "vmbr0"

  private_networks = {
    app_a = {
      bridge = "vmbr11"
      cidr   = "10.0.11.0/24"
    }
    app_b = {
      bridge = "vmbr12"
      cidr   = "10.0.12.0/24"
    }
    data = {
      bridge = "vmbr21"
      cidr   = "10.0.21.0/24"
    }
  }
}

module "compute" {
  source         = "../../modules/compute"
  node_name      = "pve"
  image_id       = data.proxmox_file.ubuntu.id
  ssh_public_key = trimspace(file(pathexpand("~/.ssh/logiandes_ed25519.pub")))

  machines = {
    app-a = {
      vm_id = 210
      ram   = 1024
      nics  = [{ bridge = "vmbr11", cidr = "10.0.11.10/24" }]
    }
    app-b = {
      vm_id = 211
      ram   = 1024
      nics  = [{ bridge = "vmbr12", cidr = "10.0.12.10/24" }]
    }
    lb = {
      vm_id = 212
      ram   = 1024
      nics = [
        { bridge = "vmbr0", cidr = "192.168.204.20/24", gateway = "192.168.204.2" },
        { bridge = "vmbr11", cidr = "10.0.11.2/24" },
        { bridge = "vmbr12", cidr = "10.0.12.2/24" }
      ]
    }
    bastion = {
      vm_id = 213
      ram   = 1024
      nics = [
        { bridge = "vmbr0", cidr = "192.168.204.21/24", gateway = "192.168.204.2" },
        { bridge = "vmbr11", cidr = "10.0.11.3/24" },
        { bridge = "vmbr12", cidr = "10.0.12.3/24" }
      ]
    }
  }

  depends_on = [module.network]
}

output "vm_ids" {
  value = module.compute.vm_ids
}
