
output "data_volume_ids" {
  value       = [for b in oci_core_volume.these : b.id]
  description = "The OCID of each volume"
}