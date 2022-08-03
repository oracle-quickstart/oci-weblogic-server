
output "tag_namespace_id" {
  value       = join("", oci_identity_tag_namespace.wlsoci_tag_namespace.*.id)
  description = "The OCID of the WebLogic for OCI tag namespace"
}

output "tag_namespace" {
  value       = join("", oci_identity_tag_namespace.wlsoci_tag_namespace.*.name)
  description = "WebLogic for OCI tag namespace"
}

output "system_tag_value" {
  value       = local.system_tag_value
  description = "Free-form tags to be added to the OCI resources"
}

#Values for creating DG rule
output "dg_tag_key" {
  value       = var.create_dg_tags && length(time_sleep.tag_creation_delay) > 0 ? time_sleep.tag_creation_delay[0].triggers["dg_tag_key_name"] : ""
  description = "WebLogic for OCI tag key for dynamic group"
}

output "dg_tag_value" {
  value       = local.system_defined_dg_tag_value
  description = "WebLogic for OCI tag value for dynamic group"
}
