# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "use_autoscaling" {
  type        = bool
  description = "Indicating that autoscaling is enabled"
  default     = false
}

variable "notification_email" {
  type        = string
  description = "Email address for notifying user when autoscaling completes"
  default     = ""
}

variable "alarm_severity" {
  type        = string
  description = "The perceived type of response required when the alarm is in the FIRING state"
  default     = "CRITICAL"
}

variable "min_threshold_percent" {
  type        = number
  description = "Minimum threshold in percentage for the metric"
  default     = 0
}

variable "max_threshold_percent" {
  type        = number
  description = "Maximum threshold in percentage for the metric"
  default     = 0
}

variable "min_threshold_counter" {
  type        = number
  description = "Minimum threshold count for the metric"
  default     = 0
}

variable "max_threshold_counter" {
  type        = number
  description = "Maximum threshold count for the metric"
  default     = 0
}

variable "wls_metric" {
  type        = string
  description = "Metric to use for triggering scaling actions. Default is CPU Load"
  default     = "CPU Load"
}

variable "ocir_region" {
  type        = string
  description = "URL to Oracle Cloud Infrastructure Registry"
  default     = ""
}

variable "ocir_user" {
  type        = string
  description = "User for Oracle Cloud Infrastructure Registry login"
  default     = ""
}

variable "ocir_auth_token_id" {
  type        = string
  description = "Secrets Oracle Cloud ID (OCID) for Oracle Cloud Infrastructure Registry authorization token"
  default     = ""
}
