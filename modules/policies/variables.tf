# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "tenancy_id" {
  type        = string
  description = "The OCID of the tenancy where the dynamic group and policy will be created"
  validation {
    condition     = length(regexall("^ocid1.tenancy.*$", var.tenancy_id)) > 0
    error_message = "The value for tenancy_id should start with \"ocid1.tenancy.\"."
  }
}

variable "compartment_id" {
  type        = string
  description = "The OCID of the compartment for the matching rule of dynamic group"
  validation {
    condition     = length(regexall("^ocid1.compartment.*$", var.compartment_id)) > 0
    error_message = "The value for compartment_id should start with \"ocid1.compartment.\"."
  }
}

variable "resource_name_prefix" {
  type        = string
  description = "Prefix used to name resources created by this module"
  validation {
    condition     = var.resource_name_prefix != ""
    error_message = "The value for resource_name_prefix cannot be empty."
  }
}

variable "tags" {
  type = object({
    defined_tags  = map(any),
    freeform_tags = map(any)
  })
  description = "Defined tags and freeform tags to be added to the policy"
  default = {
    defined_tags  = {},
    freeform_tags = {}
  }
}

variable "dynamic_group_rule" {
  type        = string
  description = "Value of the tag to be used to identify resources that should be included in the dynamic groups for the policies"
}

variable "wls_admin_password_id" {
  type        = string
  description = "The OCID of the vault secret containing the password for the WebLogic administration user"
}


variable "atp_db" {
  type = object({
    is_atp         = bool
    compartment_id = string
    password_id    = string
  })
  description = <<-EOT
  atp_db = {
    is_atp: "Indicates if an ATP database is used to store the schemas of a JRF WebLogic domain"
    compartment_id: "The OCID of the compartment where the ATP database is located"
    password_id: "The OCID of the vault secret with the password of the database"
  }
  EOT
}
