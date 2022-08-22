# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  dns_label = replace(var.dns_label,"-","")
}

data "oci_core_vcns" "wls_vcn" {
  #Required
  compartment_id = var.compartment_id

  #Optional
  filter {
    name   = "id"
    values = [var.vcn_id]
  }
}

resource "oci_core_subnet" "wls-subnet" {
  cidr_block                 = var.cidr_block
  display_name               = var.subnet_name
  dns_label                  = local.dns_label
  compartment_id             = var.compartment_id
  vcn_id                     = var.vcn_id
  security_list_ids          = var.security_list_ids
  # Dont attach the route table for peered vcn here. It will be done in VCN peering module after LPG is created.
  route_table_id             = !var.is_vcn_peered ? var.route_table_id : ""
  dhcp_options_id            = var.is_vcn_peered ? lookup(data.oci_core_vcns.wls_vcn.virtual_networks[0], "default_dhcp_options_id") : var.dhcp_options_id

  defined_tags               = var.tags.defined_tags
  freeform_tags              = var.tags.freeform_tags
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}
