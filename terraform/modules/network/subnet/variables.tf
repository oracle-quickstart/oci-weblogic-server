# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "compartment_id" {
  type        = string
  description = "The OCID of the compartment where the subnet will be created"
  validation {
    condition     = length(regexall("^ocid1.compartment.*$", var.compartment_id)) > 0
    error_message = "WLSC-ERROR: The value for compartment_id should start with \"ocid1.compartment.\"."
  }
}

variable "dns_label" {
  type        = string
  description = "A DNS label for the subnet, used in conjunction with the VNIC's hostname and VCN's DNS label to form a fully qualified domain name (FQDN) for each VNIC within this subnet"
}

variable "vcn_id" {
  type        = string
  description = "The OCID of the VCN to contain the subnet"
}

variable "dhcp_options_id" {
  type        = string
  description = "The OCID of the set of DHCP options the subnet will use"
}

variable "route_table_id" {
  type        = string
  description = "The OCID of the route table the subnet will use"
}

variable "cidr_block" {
  type        = string
  description = "The subnet's CIDR block"
}

variable "subnet_name" {
  type        = string
  description = "A user-friendly subnet name"
}

variable "prohibit_public_ip" {
  type        = bool
  description = "Set to true to create a private subnet"
}

variable "tags" {
  type = object({
    defined_tags  = map(any),
    freeform_tags = map(any),
  })
  description = "Defined tags and freeform tags to be added to the VCN"
  default = {
    defined_tags  = {},
    freeform_tags = {},
  }
}
