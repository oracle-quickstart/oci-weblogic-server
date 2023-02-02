# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_core_dhcp_options" "wls_dhcp_options" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "${var.resource_name_prefix}-${var.dhcp_options_name}"

  // required
  options {
    type        = "DomainNameServer"
    server_type = "VcnLocalPlusInternet"
  }

  defined_tags  = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}
