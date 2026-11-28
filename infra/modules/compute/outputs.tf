output "vm_ids" {
  description = "Identificadores de las VMs creadas en el pool LogiAndes"
  value = {
    for name, vm in proxmox_virtual_environment_vm.servers :
    name => vm.vm_id
  }
}
