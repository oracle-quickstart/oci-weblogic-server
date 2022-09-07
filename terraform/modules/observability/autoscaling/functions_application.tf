# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_functions_application" "wlsc_autoscaling_function_application" {

  #Required
  compartment_id = var.compartment_id
  display_name   = var.fn_application_name
  subnet_ids     = formatlist(var.wls_subnet_id)

  #Optional
  config = local.function_config_map

  defined_tags  = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags

  lifecycle {
    ignore_changes = all
  }
}
