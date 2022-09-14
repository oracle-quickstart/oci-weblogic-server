# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_core_network_security_group" "nsg" {
  #Required
  compartment_id = var.compartment_id
  vcn_id = var.vcn_id

  #Optional
  display_name               = var.nsg_name
  defined_tags               = var.tags.defined_tags
  freeform_tags              = var.tags.freeform_tags

  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}