# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_file_storage_export_set" "mount_export_set" {

  #Required
  mount_target_id = local.mount_target_id[0]
  display_name    = "${var.resource_name_prefix}-export-set"
}
