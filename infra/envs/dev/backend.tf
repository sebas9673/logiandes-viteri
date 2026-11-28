variable "state_passphrase" {
  description = "Clave privada para cifrar el estado de OpenTofu"
  type        = string
  sensitive   = true
}

terraform {
  backend "http" {}

  encryption {
    key_provider "pbkdf2" "state" {
      passphrase = var.state_passphrase
    }

    method "aes_gcm" "state" {
      keys = key_provider.pbkdf2.state
    }

    state {
      method = method.aes_gcm.state
    }
  }
}
