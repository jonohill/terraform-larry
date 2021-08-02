
# Read user, tenancy from configuration file.
# There's probably a better way to do this that I haven't figured out

data "local_file" "oci_config" {
  filename = pathexpand("~/.oci/config")
}
locals {
  oci_user_id    = regex("user\\s*=\\s*(.+)", data.local_file.oci_config.content)[0]
  oci_tenancy_id = regex("tenancy\\s*=\\s*(.+)", data.local_file.oci_config.content)[0]
}

module "box" {
  source = "./box"

  compartment_id   = local.oci_tenancy_id
  ssh_key          = var.ssh_key
  compose_repo     = var.compose_repo
  compose_sops_key = var.compose_sops_key
}

output "ip" {
  value = module.box.public_ip
}
