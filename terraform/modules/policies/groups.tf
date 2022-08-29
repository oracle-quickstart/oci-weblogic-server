# Copyright (c) 2022, Oracle and/or its affiliates.
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

