resource "oci_core_virtual_network" "wls_vcn" {

  cidr_block     = var.wls_vcn_cidr
  dns_label      = format("%svcn",substr((var.resource_name_prefix), 0, 10))
  compartment_id = var.compartment_id
  display_name   = "${var.resource_name_prefix}-${var.vcn_name}"

  defined_tags = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags
}
