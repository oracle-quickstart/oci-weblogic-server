
resource "oci_identity_policy" "wlsc_oci_policy" {

  compartment_id = var.tenancy_id
  description    = "Policy required for WLS on OCI"
  name           = "${local.label_prefix}-oci-policy"
  statements     = local.policy_statements

  defined_tags  = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags
}

