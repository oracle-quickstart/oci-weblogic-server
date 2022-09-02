# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

output "mount_target_id" {
  value = local.mount_target_id[0]
}

output "mount_export_id" {
  value = oci_file_storage_export.mount_export.id
}

output "fss_id" {
  value = oci_file_storage_file_system.file_system.id
}

output "export_path" {
  value = oci_file_storage_export.mount_export.path
}

output "mount_ip" {
  value = data.oci_file_storage_mount_targets.new_mount_target[0].mount_targets[0].private_ip_ids[0]
}
