# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

output "mountTarget_id" {
  value = local.mount_target_id[0]
}

output "mount_export_id" {
  value = oci_file_storage_export.mount_export.id
}

output "fss_id" {
  value = var.fss_system_id
}

output "nfs_mount_ip" {
  value = join("", data.oci_core_private_ip.mount_target_private_ip.*.ip_address)
}

output "nfs_export_path" {
  value = oci_file_storage_export.mount_export.path
}


