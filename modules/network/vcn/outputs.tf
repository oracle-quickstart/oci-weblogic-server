# Output of the vcn creation
output "VcnID" {
  description = "OCID of VCN that is created"
  value       = local.vcn_id
}

output "VcnCIDR" {
  description = "CIDR value of VCN that is created"
  value       = local.vcn_cidr
}
