variable "ssh_key" {
  description = "SSH public key to be added to authorized_keys"
}

variable "compose_repo" {
  description = "Repo containing a docker-compose file to be brought up on boot"
}

variable "compose_sops_key" {
  description = "age secret key for decrypting compose secrets"
  sensitive   = true
}
