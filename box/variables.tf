variable "compartment_id" {}

variable "name" {
  default = "free"
}

variable "cpus" {
  default = 4
}

variable "ram" {
  default = 24
}

variable "hdd" {
  default = 200
}

variable "ssh_key" {}

variable "compose_repo" {}

variable "compose_sops_key" {
  sensitive = true
}
