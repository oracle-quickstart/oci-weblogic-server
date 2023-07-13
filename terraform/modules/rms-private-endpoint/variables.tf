# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "compartment_id" {
  type        = string
  description = "The OCID of the compartment where the file system exists"
  validation {
    condition     = length(regexall("^ocid1.compartment.*$", var.compartment_id)) > 0 || length(regexall("^ocid1.tenancy.*$", var.compartment_id)) > 0
    error_message = "WLSC-ERROR: The value for compartment_id should start with \"ocid1.compartment.\" or \"ocid1.tenancy.\"."
  }
}

variable "vcn_id" {
  type        = string
  description = "The OCID of the VCN  where the rms private endpoint  will be created"
}

variable "private_endpoint_subnet_id" {
  type        = string
  description = "The OCID of the subnet where the rms private endpoint exists"
}

variable "private_endpoint_nsg_id" {
  type        = list(any)
  description = "The list of NSG OCIDs associated with the rms private endpoint"
  default     = []
}

variable "tags" {
  type = object({
    defined_tags  = map(any),
    freeform_tags = map(any),
  })
  description = "Defined tags and freeform tags to be added to the rms endpoint resources"
  default = {
    defined_tags  = {},
    freeform_tags = {},
  }
}

variable "resource_name_prefix" {
  type        = string
  description = "Prefix which will be used to create rms private endpoint resources"
}
