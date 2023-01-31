# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_identity_dynamic_group" "wlsc_instance_principal_group" {
  compartment_id = var.tenancy_id
  description    = "Dynamic group to allow access to resources with specific tags and allow instances to call osms services"
  matching_rule  = "ALL { ${local.compartment_rule}, ${var.dynamic_group_rule} }"
  name           = "${local.label_prefix}-wlsc-principal-group"

  lifecycle {
    ignore_changes = [matching_rule]
  }
}

resource "oci_identity_dynamic_group" "wlsc_functions_principal_group" {
  count          = var.use_autoscaling ? 1 : 0
  compartment_id = var.tenancy_id
  description    = "Dynamic group to allow OCI functions to call ORM stack APIs"
  matching_rule  = local.functions_rule
  name           = "${local.label_prefix}-functions-principal-group"
  lifecycle {
    ignore_changes = [matching_rule]
  }
}

