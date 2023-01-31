# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

# Output of the vcn creation
output "vcn_id" {
  description = "The OCID of the new VCN"
  value       = oci_core_virtual_network.wls_vcn.id
}

output "vcn_cidr" {
  description = "The CIDR value of the new VCN"
  value       = oci_core_virtual_network.wls_vcn.cidr_block
}
