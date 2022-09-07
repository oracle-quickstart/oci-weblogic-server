# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_monitoring_alarm" "wlsc_scaleout_monitoring_alarm" {
  count = length(oci_ons_notification_topic.wlsc_scaleout_notification_topic) > 0 ? 1 : 0

  #Required
  compartment_id        = var.compartment_id
  body                  = local.alarm_body[format("%s ScaleOut", var.wls_metric)]
  destinations          = formatlist(oci_ons_notification_topic.wlsc_scaleout_notification_topic[count.index].id)
  display_name          = format("%s_scaleout_monitoring_alarm", var.service_prefix_name)
  is_enabled            = var.create_policies
  metric_compartment_id = var.metric_compartment_id
  namespace             = var.alarm_namspace
  query                 = local.alarm_mql_map[format("%s ScaleOut", var.wls_metric)]
  severity              = var.alarm_severity

  #Optional
  message_format               = var.alarm_message_format
  repeat_notification_duration = "PT20M"
  pending_duration             = "PT5M"

  defined_tags  = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags

  lifecycle {
    ignore_changes = all
  }
}

resource "oci_monitoring_alarm" "wlsc_scalein_monitoring_alarm" {
  count = length(oci_ons_notification_topic.wlsc_scalein_notification_topic) > 0 ? 1 : 0

  #Required
  compartment_id        = var.compartment_id
  body                  = local.alarm_body[format("%s ScaleOut", var.wls_metric)]
  destinations          = formatlist(oci_ons_notification_topic.wlsc_scalein_notification_topic[count.index].id)
  display_name          = format("%s_scalein_monitoring_alarm", var.service_prefix_name)
  is_enabled            = var.create_policies
  metric_compartment_id = var.metric_compartment_id
  namespace             = var.alarm_namspace
  query                 = local.alarm_mql_map[format("%s ScaleIn", var.wls_metric)]
  severity              = var.alarm_severity

  #Optional
  message_format               = var.alarm_message_format
  repeat_notification_duration = "PT30M"
  pending_duration             = "PT5M"

  defined_tags  = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags

  lifecycle {
    ignore_changes = all
  }
}
