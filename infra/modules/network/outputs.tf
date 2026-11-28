output "public_bridge" {
  value = var.public_bridge
}

output "private_bridges" {
  value = {
    for key, net in var.private_networks :
    key => net.bridge
  }
}

output "private_cidrs" {
  value = {
    for key, net in var.private_networks :
    key => net.cidr
  }
}
