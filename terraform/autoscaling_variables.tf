# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "use_autoscaling" {
  type = bool
  // Possible values are None, Metric
  default     = false
  description = "Indicating that autoscaling is enabled"
}

variable "notification_email" {
  type        = string
  default     = ""
  description = "Email address for notifying user when autoscaling completes"
}

variable "alarm_severity" {
  type        = string
  default     = "CRITICAL"
  description = "The perceived type of response required when the alarm is in the FIRING state"
}

variable "min_threshold_percent" {
  type        = number
  default     = 0
  description = "Minimum threshold in percentage for the metric"
}

variable "max_threshold_percent" {
  type        = number
  default     = 0
  description = "Maximum threshold in percentage for the metric"
}

variable "min_threshold_counter" {
  type        = number
  default     = 0
  description = "Minimum threshold count for the metric"
}

variable "max_threshold_counter" {
  type        = number
  default     = 0
  description = "Maximum threshold count for the metric"
}

variable "wls_metric" {
  type        = string
  default     = "CPU Load"
  description = "Metric to use for triggering scaling actions. Default is metrics-based autoscaling"
}

variable "ocir_region" {
  type        = string
  default     = ""
  description = "URL to Oracle Cloud Infrastructure Registry"
}
variable "ocir_user" {
  type        = string
  default     = ""
  description = "User for Oracle Cloud Infrastructure Registry login"
}
variable "ocir_auth_token_ocid" {
  type        = string
  default     = ""
  description = "Secrets Oracle Cloud ID (OCID) for Oracle Cloud Infrastructure Registry authorization token"
}
