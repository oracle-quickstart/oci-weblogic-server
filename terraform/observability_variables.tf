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