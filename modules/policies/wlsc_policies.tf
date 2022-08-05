locals {
  # TODO Add other policy statements
  policy_statements = ["Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group[0].name} to manage instance-family in compartment id ${var.compartment_id}"]
  label_prefix      = replace(var.service_name, "/[^a-zA-Z0-9]/", "")
}

resource "oci_identity_policy" "wlsc_oci_policy" {
  count = var.create_policies ? 1 : 0

  compartment_id = var.tenancy_id
  description    = "Policy required for WLS on OCI"
  name           = "${local.label_prefix}-oci-policy"
  statements     = local.policy_statements

  defined_tags  = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags
}

