resource "oci_core_virtual_network" "wls_vcn" {
  // If vcn_name is provided and existing subnets are not used then we create VCN regardless of existing vcn_id value.
  // So vcn_name has preference.
  // If user wants to use existing vcn_id, then don't provide vcn_name and new VCN won't be created.
  count = var.vcn_name !="" && var.use_existing_subnets==false ? 1:0

  cidr_block     = var.wls_vcn_cidr
  dns_label      = format("%svcn",substr((var.resource_name_prefix), 0, 10))
  compartment_id = var.compartment_id
  display_name   = "${var.resource_name_prefix}-${var.vcn_name}"

  defined_tags = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags
}
