# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_file_storage_mount_targets" "new_mount_target" {

  count = var.mount_target_id == "" ? 1 : 0
  #Required
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id

  id = var.mount_target_id
}
