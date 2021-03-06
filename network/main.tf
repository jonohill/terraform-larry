data "oci_identity_availability_domain" "ad" {
  compartment_id = var.compartment_id
  ad_number      = 1
}

resource "oci_core_vcn" "vcn" {
  cidr_block     = "10.1.0.0/16"
  compartment_id = var.compartment_id
  display_name   = "${var.name}_vcn"
  dns_label      = var.name
}

resource "oci_core_default_security_list" "default_security_list" {
  compartment_id             = var.compartment_id
  manage_default_resource_id = resource.oci_core_vcn.vcn.default_security_list_id

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  dynamic "ingress_security_rules" {
    for_each = toset(var.udp_ports)

    content {
      protocol = "17" # udp
      source   = "0.0.0.0/0"

      udp_options {
        min = ingress_security_rules.key
        max = ingress_security_rules.key
      }
    }
  }
}

resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = var.compartment_id
  display_name   = "${var.name}_ng"
  vcn_id         = oci_core_vcn.vcn.id
}

resource "oci_core_default_route_table" "route_table" {
  manage_default_resource_id = oci_core_vcn.vcn.default_route_table_id
  display_name               = "${var.name}_rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
}

resource "oci_core_subnet" "subnet" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  cidr_block          = "10.1.20.0/24"
  display_name        = "${var.name}_subnet"
  dns_label           = var.name
  security_list_ids   = [oci_core_vcn.vcn.default_security_list_id]
  compartment_id      = var.compartment_id
  vcn_id              = oci_core_vcn.vcn.id
  route_table_id      = oci_core_vcn.vcn.default_route_table_id
  dhcp_options_id     = oci_core_vcn.vcn.default_dhcp_options_id
}
