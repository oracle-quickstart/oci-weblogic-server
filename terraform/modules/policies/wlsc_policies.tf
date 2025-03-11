# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_identity_policy" "wlsc_oci_policy" {

  compartment_id = var.tenancy_id
  description    = "Policy required for WLS on OCI"
  name           = "${local.label_prefix}-oci-policy"
  statements     = local.policy_statements

  defined_tags  = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}


resource "oci_identity_policy" "wlsc_oci_policy_autoscaling" {

  count = var.use_autoscaling?1:0

  compartment_id = var.tenancy_id
  description    = "Autoscaling Policies required for WLS on OCI"
  name           = "${local.label_prefix}-oci-policy-autoscaling"
  statements     = local.autoscaling_statements

  defined_tags  = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}