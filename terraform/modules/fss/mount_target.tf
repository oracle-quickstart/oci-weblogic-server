# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_file_storage_mount_target" "mount_target" {

  count = var.mount_target_id == "" ? 1 : 0

  #Required
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  subnet_id           = var.mount_target_subnet_id
  nsg_ids             = var.mount_target_nsg_id

  display_name   = "${var.resource_name_prefix}-mntTarget"
  hostname_label = "${var.resource_name_prefix}-mntTarget"

  defined_tags = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags

  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }

}
