# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "tenancy_id" {
  type        = string
  description = "The OCID of the tenancy where the WebLogic for OCI stack will be created"
}

variable "region" {
  type        = string
  description = "The region where the WebLogic for OCI stack will be created"
}

variable "compartment_id" {
  type        = string
  description = "The OCID of the compartment where new resources for the the WebLogic for OCI stack will be created"
}

variable "service_name" {
  type        = string
  description = "This value will be used as prefix for several resources"
}

variable "ssh_public_key" {
  type        = string
  description = "Public key for ssh access to WebLogic compute instances. Use the corresponding private key to access the WebLogic compute instances"
}

variable "create_policies" {
  type        = bool
  description = "Set to true to create OCI IAM policies and dynamic groups required by the WebLogic for OCI stack. If this is set to false, the policies and dynamic groups need to be created manually"
  default     = true
}

variable "generate_dg_tag" {
  type        = bool
  description = "Set to true to generate defined tags for dynamic group definition."
  default     = false
}

variable "service_tags" {
  type = object({
    freeformTags = map(any)
    definedTags  = map(any)
  })
  description = "Tags to be applied to all resources that support tag created by the WebLogic for OCI stack"
  default     = { freeformTags = {}, definedTags = {} }
}
