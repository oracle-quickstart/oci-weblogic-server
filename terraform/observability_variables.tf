# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "use_oci_logging" {
  type = bool
  default = false
  description = "flag indicating that oci logging service is enabled"
}

variable "dynamic_group_ocid" {
  type        = string
  default     = ""
  description = "dynamic group ocid for oci logging agent configuration when create policies is not set"
}