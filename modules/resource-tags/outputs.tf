
output "tag_namespace_id" {
  value = join("", oci_identity_tag_namespace.wlsoci_tag_namespace.*.id)
}

output "tag_namespace" {
  value = join("", oci_identity_tag_namespace.wlsoci_tag_namespace.*.name)
}

output "system_tag_value" {
  value = local.system_tag_value
}

#Values for creating DG rule
output "dg_tag_key" {
  value = var.create_dg_tags && length(time_sleep.tag_creation_delay) > 0 ? time_sleep.tag_creation_delay[0].triggers["dg_tag_key_name"] : ""
}

output "dg_tag_value" {
  value = local.system_defined_dg_tag_value
}
