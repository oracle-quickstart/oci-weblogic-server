# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "use_oci_logging" {
  type = bool
  description = "Enable logging service integration for WebLogic instances"
  default = false
}

variable "dynamic_group_id" {
  type        = string
  description = "The dynamic group that contains the WebLogic instances from which logs will be exported to OCI Logging Service"
  default     = ""
}

variable "use_apm_service" {
  type        = bool
  description = "Indicates if Application Performance Monitoring integration is enabled"
  default     = false
}

variable "apm_domain_id" {
  type        = string
  description = "The OCID of the Application Performance Monitoring domain used by WebLogic instances"
  default     = ""
}

variable "apm_private_data_key_name" {
  type        = string
  description = "The name of the private data key used by this instance to push metrics to the Application Performance Monitoring domain"
  default     = "auto_generated_private_datakey"
}