# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_ons_subscription" "wlsc_email_topic_email_subscription" {
  count = var.subscription_endpoint != "" ? 1 : 0
  #Required
  compartment_id = var.compartment_id
  endpoint       = var.subscription_endpoint
  protocol       = var.subscription_protocol
  topic_id       = oci_ons_notification_topic.wlsc_email_notification_topic[count.index].id

  defined_tags  = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags

  lifecycle {
    ignore_changes = all
  }
}

