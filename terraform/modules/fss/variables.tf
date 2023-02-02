# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "compartment_id" {
  type        = string
  description = "The OCID of the compartment where the file system exists"
  validation {
    condition     = length(regexall("^ocid1.compartment.*$", var.compartment_id)) > 0
    error_message = "WLSC-ERROR: The value for compartment_id should start with \"ocid1.compartment.\"."
  }
}

variable "availability_domain" {
  type        = string
  description = "The name of the availability domain where the file system and mount target exist"
}

variable "vcn_id" {
  type        = string
  description = "The OCID of the VCN  where the file system and mount target will be created"
}

variable "vcn_cidr" {
  type        = string
  description = "The CIDR value of the VCN  where the file system and mount target will be created"
}

variable "export_path" {
  type        = string
  description = "Path used to access the associated file system."
}

variable "mount_target_subnet_id" {
  type        = string
  description = "The OCID of the subnet where the mount target exists"
}

variable "mount_target_id" {
  type        = string
  description = "The OCID of the mount target for File Shared System"
}

variable "mount_target_compartment_id" {
  type        = string
  description = "The OCID of the compartment where the mount target exists"
}

variable "mount_target_nsg_id" {
  type        = list(any)
  description = "The list of NSG OCIDs associated with the mount target"
  default     = []
}

variable "tags" {
  type = object({
    defined_tags  = map(any),
    freeform_tags = map(any),
  })
  description = "Defined tags and freeform tags to be added to the File Shared System resources"
  default = {
    defined_tags  = {},
    freeform_tags = {},
  }
}

variable "resource_name_prefix" {
  type        = string
  description = "Prefix which will be used to create File Shared System resources"
}

variable "existing_fss_id" {
  type        = string
  description = "The OCID of the File System"
}
