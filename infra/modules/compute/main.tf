resource "proxmox_virtual_environment_vm" "servers" {
  for_each = var.machines

  name            = "logi-${each.key}"
  node_name       = var.node_name
  vm_id           = each.value.vm_id
  pool_id         = "logiandes"
  description     = "UDLA LogiAndes - ${each.key}"
  tags            = ["logiandes", "udla"]
  stop_on_destroy = true

  cpu {
    cores = 1
  }

  memory {
    dedicated = each.value.ram
  }

  disk {
    datastore_id = "local-lvm"
    import_from  = var.image_id
    interface    = "scsi0"
    size         = 6
  }

  dynamic "network_device" {
    for_each = each.value.nics
    content {
      bridge   = network_device.value.bridge
      firewall = true
    }
  }

  initialization {
    datastore_id = "local-lvm"

    dynamic "ip_config" {
      for_each = each.value.nics
      content {
        ipv4 {
          address = ip_config.value.cidr
          gateway = ip_config.value.gateway
        }
      }
    }

    user_account {
      username = "ubuntu"
      keys     = [var.ssh_public_key]
    }
  }

  operating_system {
    type = "l26"
  }

  serial_device {}
}

output "vm_ids" {
  value = {
    for name, vm in proxmox_virtual_environment_vm.servers :
    name => vm.vm_id
  }
}
