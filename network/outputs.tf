output "ad_name" {
  value = data.oci_identity_availability_domain.ad.name
}

output "subnet_id" {
  value = oci_core_subnet.subnet.id
}
