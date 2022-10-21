# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_ons_notification_topic" "wlsc_scaleout_notification_topic" {
  #Required
  compartment_id = var.compartment_id
  name           = format("%s_scaleout_notification_topic", var.service_prefix_name)

  defined_tags  = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags

  lifecycle {
    ignore_changes = all
  }
}

resource "oci_ons_notification_topic" "wlsc_scalein_notification_topic" {
  #Required
  compartment_id = var.compartment_id
  name           = format("%s_scalein_notification_topic", var.service_prefix_name)

  defined_tags  = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags

  lifecycle {
    ignore_changes = all
  }
}

# Email notification topic used solely to notify user when autoscaling completes
resource "oci_ons_notification_topic" "wlsc_email_notification_topic" {
  count = var.subscription_endpoint != "" ? 1 : 0
  #Required
  compartment_id = var.compartment_id
  name           = format("%s_email_notification_topic", var.service_prefix_name)

  defined_tags  = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags

  lifecycle {
    ignore_changes = all
  }
}
