# Output of the vcn creation
output "VcnID" {
  description = "ocid of VCN. "
  value       = local.vcn_id
}

output "VcnCIDR" {
  description = "cidr of VCN"
  value       = local.vcn_cidr
}
