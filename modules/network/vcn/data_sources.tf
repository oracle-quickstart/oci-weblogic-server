locals {
  vcn_id   = var.vcn_name != "" ? join("", oci_core_virtual_network.wls-vcn.*.id) : var.vcn_id
  vcn_cidr = var.vcn_name != "" ? join("", oci_core_virtual_network.wls-vcn.*.cidr_block) : join("", data.oci_core_vcn.existing_wls_vcn.*.cidr_block)
}

data "oci_core_vcn" "existing_wls_vcn" {
  count = var.vcn_id != "" ? 1 : 0
  #Required
  vcn_id = var.vcn_id
}
