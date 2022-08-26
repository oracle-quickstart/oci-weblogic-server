# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_file_storage_exports" "export" {
  count = var.existing_fss_id != "" ? 1 : 0

  id = var.existing_export_path_id
}

data "oci_file_storage_mount_targets" "mount_target" {
  count = var.existing_fss_id != "" ? 1 : 0
  #Required
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id

  #Optional
  export_set_id = data.oci_file_storage_exports.export[0].export_set_id
}

data "oci_core_private_ip" "mount_target_private_ip" {
  count = var.existing_fss_id != "" ? 1 : 0
  #Required
  private_ip_id = data.oci_file_storage_mount_targets.mount_target[0].mount_targets[0].private_ip_ids[0]
}

