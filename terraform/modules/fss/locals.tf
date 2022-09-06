# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  anywhere        = "0.0.0.0/0"
  vcn_cidr        = data.oci_core_vcn.wls_vcn.cidr_block
  mount_target_id = coalescelist(oci_file_storage_mount_target.mount_target.*.id, tolist([var.mount_target_id]))
}
