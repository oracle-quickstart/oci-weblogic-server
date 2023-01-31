# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_file_storage_mount_targets" "mount_target" {
  #Required
  availability_domain = var.availability_domain
  compartment_id      = var.mount_target_compartment_id
  id                  = var.mount_target_id != "" ? var.mount_target_id : join("", oci_file_storage_mount_target.mount_target.*.id)
}

data "oci_core_private_ip" "mount_target_private_ip" {
  #Required
  private_ip_id = data.oci_file_storage_mount_targets.mount_target.mount_targets[0].private_ip_ids[0]
}

