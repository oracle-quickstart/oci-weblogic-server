# Output of the vcn creation
output "vcn_id" {
  description = "The OCID of the new VCN or existing VCN"
  value       = local.vcn_id
}

output "vcn_cidr" {
  description = "The CIDR value of the new VCN or existing VCN"
  value       = local.vcn_cidr
}
