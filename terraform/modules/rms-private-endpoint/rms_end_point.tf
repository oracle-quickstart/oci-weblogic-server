# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_resourcemanager_private_endpoint" "rms_private_endpoint" {

  vcn_id         = var.vcn_id
  compartment_id = var.compartment_id
  subnet_id      = var.private_endpoint_subnet_id
  nsg_id_list    = var.private_endpoint_nsg_id

  display_name = "${var.resource_name_prefix}-pvtEndpoint"

  defined_tags  = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags

  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }

}
