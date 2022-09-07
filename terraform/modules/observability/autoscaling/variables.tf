# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "compartment_id" {
  type        = string
  description = "The OCID of the compartment where the autoscaling service resources will be created"
}

variable "service_prefix_name" {
  type        = string
  description = "Prefix for stack resources"
}

variable "tags" {
  type = object({
    defined_tags  = map(any),
    freeform_tags = map(any)
  })
  description = "Defined tags and freeform tags to be added to the autoscaling service in resources"
  default = {
    defined_tags  = {},
    freeform_tags = {}
  }
}

variable "subscription_protocol" {
  type    = string
  description = "The protocol used for the subscription"
  default = "EMAIL"
}

variable "subscription_endpoint" {
  type = string
  description = "A locator that corresponds to the subscription protocol"
}

variable "alarm_severity" {
  type    = string
  description = "The perceived type of response required when the alarm is in the FIRING state"
  default = "CRITICAL"
}

variable "min_threshold_percent" {
  type    = string
  description = "Minimum threshold in percentage for the metric"
}

variable "max_threshold_percent" {
  type    = string
  description = "Maximum threshold in percentage for the metric"
}

variable "min_threshold_counter" {
  type    = string
  description = "Minimum threshold count for the metric"
}

variable "max_threshold_counter" {
  type    = string
  description = "Maximum threshold count for the metric"
}

variable "wls_metric" {
  type = string
  description = "Metric to use for triggering scaling actions. Default is metrics-based autoscaling"
}

variable "metric_compartment_id" {
  type = string
  description = "The OCID of the compartment where the metrics will be displayed"
}

variable "alarm_namspace" {
  type    = string
  description = "The source service or application emitting the metric that is evaluated by the alarm"
  default = "oracle_apm_monitoring"
}

variable "alarm_message_format" {
  type    = string
  description = "The format to use for notification messages sent from this alarm"
  default = "ONS_OPTIMIZED"
}

variable "metric_interval" {
  type    = string
  description = "The metric interval time"
  default = "1m"
}

variable "wls_subnet_id" {
  type        = string
  description = "The OCID of the subnet for the WebLogic instances. Leave it blank if a new subnet will be created by the stack"
  default     = ""
}

variable "wls_node_count" {
  type        = number
  description = "Number of WebLogic managed servers. One VM per managed server will be created"
  default     = "1"
}

variable "tenancy_id" {
  type        = string
  description = "The OCID of the tenancy where the compute will be created"
}

variable "fn_application_name" {
  type = string
  description = "A user friendly function application name"
}

variable "fn_repo_name" {
  type = string
  description = "A user friendly function repository name"
}

variable "log_group_id" {
  type = string
  description = "The OCID of a log group to work with"
}

variable "create_policies" {
  type    = bool
  description = "Set to true if the policies need to be created"
}

variable "use_autoscaling" {
  type = string
  // Possible values are None, Metric
  description = "Set the autoscaling values to None or Metric"
  default     = "None"
}
