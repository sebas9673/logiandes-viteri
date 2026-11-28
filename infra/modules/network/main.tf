resource "proxmox_network_linux_bridge" "private" {
  for_each = var.private_networks

  node_name  = var.node_name
  name       = each.value.bridge
  comment    = "LogiAndes ${each.key} - ${each.value.cidr}"
  autostart  = true
  vlan_aware = false

  # Preparar cambios sin recargar la red del host.
  reload = false
}
