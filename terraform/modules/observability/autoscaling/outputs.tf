# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

output "scaleout_notification_topic_id" {
  value = element(concat(oci_ons_notification_topic.wlsc_scaleout_notification_topic.*.id, tolist([""])),0)
}

output "scalein_notification_topic_id" {
  value = element(concat(oci_ons_notification_topic.wlsc_scalein_notification_topic.*.id, tolist([""])),0)
}

output "email_notification_topic_id" {
  value = (var.subscription_endpoint != "" ? element(concat(oci_ons_notification_topic.wlsc_email_notification_topic.*.id, tolist([""])),0) : "")
}

output "email_subscription_id" {
  value = (var.subscription_endpoint != "" ? element(concat(oci_ons_subscription.wlsc_email_topic_email_subscription.*.id, tolist([""])),0) : "")
}

output "scaleout_monitoring_alarm" {
  value = element(concat(oci_monitoring_alarm.wlsc_scaleout_monitoring_alarm.*.id, tolist([""])),0)
}

output "scalein_monitoring_alarm" {
  value = element(concat(oci_monitoring_alarm.wlsc_scalein_monitoring_alarm.*.id, tolist([""])),0)
}

output "autoscaling_function_application_id" {
  value = element(concat(oci_functions_application.wlsc_autoscaling_function_application.*.id, tolist([""])),0)
}

output "autoscaling_scaleout_function_repo" {
  value = element(concat(oci_artifacts_container_repository.wlsc_autoscaling_function_repo_scaleout.*.id, tolist([""])),0)
}

output "autoscaling_scalein_function_repo" {
  value = element(concat(oci_artifacts_container_repository.wlsc_autoscaling_function_repo_scalein.*.id, tolist([""])),0)
}

output "autoscaling_orm_job_completion_handler_function_repo" {
  value = element(concat(oci_artifacts_container_repository.wlsc_autoscaling_function_repo_orm_job_completion_handler.*.id, tolist([""])),0)
}

output "log_id" {
  value = element(concat(oci_logging_log.wlsc_autoscaling_log.*.id, tolist([""])),0)
}
