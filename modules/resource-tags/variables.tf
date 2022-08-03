
variable "compartment_id" {
  type = string
  description = "The OCID of the compartment where the resource tags will be created"
  validation {
    condition     = length(regexall("^ocid1.compartment.*$", var.compartment_id)) > 0
    error_message = "The value for compartment_id should start with \"ocid1.compartment.\"."
  }
}

variable "service_name" {
  type = string
  description = "Service name prefix to be added to the dynamic group"
  validation {
    condition     = var.service_name != ""
    error_message = "The value for service_name cannot be empty."
  }
}

variable "is_system_tag" {
  type = bool
  description = "Flag to create freeform tags for the OCI resources"
}

variable "create_dg_tags" {
  type = bool
  description = "Flag to create defined tags for dynamic group definition"
}
