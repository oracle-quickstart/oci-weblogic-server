# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

output "fss_id" {
  value = var.existing_fss_id
}

output "nfs_mount_ip" {
  value = join("", data.oci_core_private_ip.mount_target_private_ip.*.ip_address)
}

output "nfs_export_path" {
  value = join("", [data.oci_file_storage_exports.export.0.exports[0].path])
}


