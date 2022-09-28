# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_logging_log_group" "wlsc_log_group" {
  #Required
  compartment_id = var.compartment_id
  display_name   = format("%s_log_group", var.service_prefix_name)
  description    = "WebLogic for OCI logging group"

  defined_tags  = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags
  lifecycle {
    ignore_changes = all
  }
}
