variable "node_name" {
  type = string
}

variable "image_id" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

variable "machines" {
  type = map(object({
    vm_id = number
    ram   = number
    nics = list(object({
      bridge  = string
      cidr    = string
      gateway = optional(string)
    }))
  }))
}
