# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "mount_ip" {
  type        = string
  description = "The private IP address associated with the mount target"
}

variable "mount_path" {
  type        = string
  description = "The path to mount file system storage on the WebLogic Server instances"
}

variable "export_path" {
  type        = string
  description = "Path to access the file system"
}

variable "add_fss" {
  type        = bool
  description = "Add file system storage to Weblogic Server instances"
}