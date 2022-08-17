# Output of the vcn creation
output "vcn_id" {
  description = "The OCID of the new VCN"
  value       = oci_core_virtual_network.wls_vcn.id
}

output "vcn_cidr" {
  description = "The CIDR value of the new VCN"
  value       = oci_core_virtual_network.wls_vcn.cidr_block
}
