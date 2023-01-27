# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "wls_edition" {
  type        = string
  description = "The WebLogic edition to be installed in this compute instance. Accepted values are: SE, EE, SUITE"
  default     = "EE"
  validation {
    condition     = contains(["SE", "EE", "SUITE"], var.wls_edition)
    error_message = "WLSC-ERROR: Allowed values for wls_edition are SE, EE and SUITE."
  }
}
