# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_file_storage_file_system" "file_system" {
  count = var.existing_fss_id ==""?1:0
  #Required
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id

  display_name  = "${var.resource_name_prefix}-fss"
  defined_tags  = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags

  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}
