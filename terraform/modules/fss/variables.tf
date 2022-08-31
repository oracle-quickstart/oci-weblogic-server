# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "compartment_id" {
  type        = string
  description = "The OCID of the compartment where the file system exists"
}

variable "availability_domain" {
  type        = string
  description = "The name of the availability domain where the file system and mount target exist"
}

variable "existing_fss_id" {
  type        = string
  description = "The OCID of your existing file system"
}

variable "existing_export_path_id" {
  type        = string
  description = "The OCID of the existing export path"
}


