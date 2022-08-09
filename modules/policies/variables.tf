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




