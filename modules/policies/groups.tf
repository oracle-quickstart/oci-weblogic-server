locals {
  compartment = format("instance.compartment.id='%s'", var.compartment_id)
}

resource "oci_identity_dynamic_group" "wlsc_instance_principal_group" {
  count          = var.create_policies ? 1 : 0
  compartment_id = var.tenancy_id
  description    = "Dynamic group to allow access to resources with specific tags and allow instances to call osms services"
  matching_rule  = "ALL { ${local.compartment}, ${var.dynamic_group_rule} }"
  name           = "${local.label_prefix}-wlsc-principal-group"

  lifecycle {
    ignore_changes = [matching_rule]
  }
}

