variable "node_name" {
  description = "Nodo Proxmox"
  type        = string
}

variable "public_bridge" {
  description = "Bridge publico existente"
  type        = string
}

variable "private_networks" {
  description = "Redes privadas de LogiAndes"
  type = map(object({
    bridge = string
    cidr   = string
  }))
}
