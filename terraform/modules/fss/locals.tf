# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_core_vcn" "wls_vcn" {
  #Required
  vcn_id = var.vcn_id
}

locals {
  anywhere        = "0.0.0.0/0"
  vcn_cidr        = data.oci_core_vcn.wls_vcn.cidr_block
  mount_target_id = coalescelist(oci_file_storage_mount_target.mount_target.*.id, list(var.mountTarget_id))
}
