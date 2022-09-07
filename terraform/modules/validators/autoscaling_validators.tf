# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  invalid_use_autoscaling_value     = ! contains(list("None", "Metric"), var.use_autoscaling)
  invalid_use_autoscaling_value_msg = "WLSC-ERROR: The value for use_autoscaling=[${var.use_autoscaling}] is not valid. The permissible values are [None, Metric]"
  validate_use_autoscaling_value    = local.invalid_use_autoscaling_value ? local.validators_msg_map[local.invalid_use_autoscaling_value_msg] : null

  invalid_wls_metric                  = var.use_autoscaling == "Metric" ? ! contains(list("CPU Load", "Used Heap Percent", "Stuck Threads", "Queue Length"), var.wls_metric) : false
  invalid_wls_metric_msg              = "WLSC-ERROR: The value for wls_metric=[${var.wls_metric}] is not valid. The permissible values are [CPU Load, Used Heap Percent, Stuck Threads, Queue Length]"
  validate_wls_metric_for_autoscaling = local.invalid_wls_metric ? local.validators_msg_map[local.invalid_wls_metric_msg] : null

  invalid_min_max_thresholds                                = (var.use_autoscaling == "Metric" && var.wls_metric != "None" && ((var.max_threshold_percent < var.min_threshold_percent) || (var.max_threshold_counter < var.min_threshold_counter)))
  invalid_metric_based_autoscaling_min_max_msg              = "WLSC-ERROR: The value for min [min_threshold] should be less than or equal to max threshold [max_threshold]"
  validate_min_max_thresholds_for_metrics_based_autoscaling = local.invalid_min_max_thresholds ? local.validators_msg_map[local.invalid_metric_based_autoscaling_min_max_msg] : null

  invalid_min_max_thresholds_values                                = var.use_autoscaling == "Metric" && var.wls_metric != "None" && (var.min_threshold_percent < 0 || var.min_threshold_percent > 100 || var.max_threshold_percent < 0 || var.max_threshold_percent > 100 || var.min_threshold_counter < 0 || var.max_threshold_counter < 0)
  invalid_metric_based_autoscaling_min_max_value_msg               = "WLSC-ERROR: Invalid value of min_threshold and/or max_threshold. For min[max]_threshold_percent value should be [0..100] and for min[max]_threshold_counter value should be >= 0."
  validate_min_max_thresholds_for_metrics_based_autoscaling_values = local.invalid_min_max_thresholds_values ? local.validators_msg_map[local.invalid_metric_based_autoscaling_min_max_value_msg] : null

  invalid_autoscaling_enabled     = var.use_autoscaling == "Metric" && ! var.use_apm_service
  invalid_autoscaling_enabled_msg = "WLSC-ERROR: Metric based autoscaling requires APM service integration to be enabled"
  validate_autoscaling_enabled    = local.invalid_autoscaling_enabled ? local.validators_msg_map[local.invalid_autoscaling_enabled_msg] : null

  invalid_ocir_auth_token_id_msg = "WLSC-ERROR: The value for OCIR Authorization Token [ocir_auth_token_ocid] is not valid. The value must begin with ocid1 followed by resource type, e.g. ocid1.vaultsecret."
  validate_ocir_auth_token_id    = var.use_autoscaling != "None" && length(regexall("^ocid1.vaultsecret.", var.ocir_auth_token_id)) <= 0 ? local.validators_msg_map[local.invalid_ocir_auth_token_id_msg] : null

  missing_lb_configured_msg      = "WLSC-ERROR: Metrics based autoscaling requires the Load Balancer to distribute application traffic to the managed servers in the domain. Please edit the stack, configure the load balancer and apply the stack."
  validate_lb_configured         = var.use_autoscaling != "None" && !var.add_load_balancer ? local.validators_msg_map[local.missing_lb_configured_msg] : null
}
