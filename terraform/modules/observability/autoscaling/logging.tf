# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_logging_log" "wlsc_autoscaling_log" {
  count        = length(oci_functions_application.wlsc_autoscaling_function_application) > 0 ? 1 : 0
  #Required
  display_name = format("%s_autoscaling_log", var.service_prefix_name)
  log_group_id = var.log_group_id
  log_type     = "SERVICE"
  is_enabled   = true

  #Optional
  configuration {
    #Required
    source {
      #Required
      category    = "invoke"
      resource    =  oci_functions_application.wlsc_autoscaling_function_application[count.index].id
      service     = "functions"
      source_type = "OCISERVICE"
    }

    #Optional
    compartment_id = var.compartment_id
  }

  defined_tags = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags

  lifecycle {
    ignore_changes = all
  }
}
