# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "compartment_id" {
  type        = string
  description = "The OCID of the compartment where the nsg will be created"
  validation {
    condition     = length(regexall("^ocid1.compartment.*$", var.compartment_id)) > 0
    error_message = "WLSC-ERROR: The value for compartment_id should start with \"ocid1.compartment.\"."
  }
}

variable "nsg_name" {
  type = string
  description = "A user-friendly nsg name"
}

variable "vcn_id" {
  type = string
  description = "The OCID of the VCN to contain the nsg"
}

variable "tags" {
  type = object({
    defined_tags    = map(any),
    freeform_tags   = map(any),
  })
  description = "Defined tags and freeform tags to be added to the VCN"
  default = {
    defined_tags    = {},
    freeform_tags   = {},
  }
}
