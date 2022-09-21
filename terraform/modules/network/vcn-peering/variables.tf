# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "resource_name_prefix" {
  type        = string
  description = "The prefix to be used in the names of resources created in this module"
}

variable "wls_network_compartment_id" {
  type        = string
  description = "The OCID of the compartment for the network resources, like VCN, for the WebLogic servers"
  validation {
    condition     = length(regexall("^ocid1.compartment.*$", var.wls_network_compartment_id)) > 0
    error_message = "WLSC-ERROR: The value for wls_network_compartment_id should start with \"ocid1.compartment.\"."
  }
}

variable "wls_vcn_id" {
  type        = string
  description = "The OCID of the VCN for the WebLogic servers"
  validation {
    condition     = length(regexall("^ocid1.vcn.*$", var.wls_vcn_id)) > 0
    error_message = "WLSC-ERROR: The value for wls_vcn_id should start with \"ocid1.vcn.\"."
  }
}

variable "wls_subnet_id" {
  type        = string
  description = "The OCID of the subnet for the WebLogic servers"
  validation {
    condition     = length(regexall("^ocid1.subnet.*$", var.wls_subnet_id)) > 0
    error_message = "WLSC-ERROR: The value for wls_subnet_id should start with \"ocid1.subnet.\"."
  }
}

variable "is_existing_wls_vcn" {
  type        = bool
  description = "Set to true if the VCN for WebLogic is not created with the WebLogic for OCI stack, but it was created before"
}

variable "wls_service_gateway_id" {
  type        = string
  description = "The OCID of the service gateway in the VCN for WebLogic servers"
  validation {
    condition     = length(regexall("^ocid1.servicegateway.*$", var.wls_service_gateway_id)) > 0
    error_message = "WLSC-ERROR: The value for wls_service_gateway_id should start with \"ocid1.servicegateway.\"."
  }
}

variable "wls_internet_gateway_id" {
  type        = string
  description = "The OCID of the service gateway in the VCN for WebLogic servers"
  validation {
    condition     = length(regexall("^ocid1.internetgateway.*$", var.wls_internet_gateway_id)) > 0
    error_message = "WLSC-ERROR: The value for wls_internet_gateway_id should start with \"ocid1.internetgateway.\"."
  }
}

variable "is_wls_subnet_public" {
  type        = bool
  description = "Indicates if the subnet for the WebLogic servers is public and the VMs for WebLogic have a public IP assigned"
}

variable "db_vcn_id" {
  type        = string
  description = "The OCID of the VCN for the OCI DB or ATP DB (when using private endpoint)"
  validation {
    condition     = length(regexall("^ocid1.vcn.*$", var.db_vcn_id)) > 0
    error_message = "WLSC-ERROR: The value for db_vcn_id should start with \"ocid1.vcn.\"."
  }
}

variable "db_subnet_id" {
  type        = string
  description = "The OCID of the subnet for the OCI DB or ATP DB (when using private endpoint)"
  validation {
    condition     = length(regexall("^ocid1.subnet.*$", var.db_subnet_id)) > 0
    error_message = "WLSC-ERROR: The value for db_subnet_id should start with \"ocid1.subnet.\"."
  }
}

variable "db_vcn_lpg_id" {
  type        = string
  description = "The OCID of the LPG in the OCI DB VCN or ATP DB VCN to which the LPG for the WebLogic VCN will be peered"
  validation {
    condition     = length(regexall("^ocid1.localpeeringgateway.*$", var.db_vcn_lpg_id)) > 0
    error_message = "WLSC-ERROR: The value for db_vcn_lpg_id should start with \"ocid1.localpeeringgateway.\"."
  }
}

variable "tags" {
  type = object({
    defined_tags  = map(any),
    freeform_tags = map(any),
  })
  description = "Defined tags and freeform tags to be added to all resources in the module"
  default = {
    defined_tags  = {},
    freeform_tags = {},
  }
}
