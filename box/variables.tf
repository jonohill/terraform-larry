variable "compartment_id" {}

variable "ad_name" {}

variable "subnet_id" {}

variable "name" {
  default = "free"
}

variable "shape" {
  default = "VM.Standard.A1.Flex"
}

variable "cpus" {
  default = 4
}

variable "ram" {
  default = 24
}

variable "hdd" {
  default = 50
}

variable "data_hdd" {
  default = 150
}

variable "ssh_key" {}

variable "ssh_ca_key" {
  sensitive = true
}

variable "compose_repo" {}

variable "compose_sops_key" {
  sensitive = true
}
