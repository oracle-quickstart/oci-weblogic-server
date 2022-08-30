# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "add_fss" {
  type        = bool
  description = "Add file system storage to WebLogic Server instances"
  default     = false
}

variable "fss_availability_domain" {
  type        = string
  description = "The name of the availability domain where the file system and mount target exists"
  default     = ""
}

variable "mount_path" {
  type        = string
  description = "The path to mount file system storage on the WebLogic Server instances"
  default     = "/u01/shared"
}

variable "existing_fss_id" {
  type        = string
  description = "The OCID of your existing file system"
  default     = ""
}

variable "existing_export_path_id" {
  type        = string
  description = "The OCID of the existing export path"
  default     = ""
}

variable "fss_compartment_id" {
  type        = string
  description = "The OCID of the compartment where the file system exists"
  default     = ""
}

variable "add_existing_fss" {
  type        = bool
  description = "Use an existing file system"
  default     = false
}