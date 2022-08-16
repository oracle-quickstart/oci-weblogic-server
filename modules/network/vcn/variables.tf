variable "compartment_id" {
  type        = string
  description = "The OCID of the compartment where the vcn will be created"
  validation {
    condition     = length(regexall("^ocid1.compartment.*$", var.compartment_id)) > 0
    error_message = "The value for compartment_id should start with \"ocid1.compartment.\"."
  }
}

variable "vcn_name" {
  type        = string
  description = "A user-friendly VCN name that will be created"
  default     = "wls-vcn"
}

variable "vcn_id" {
  type        = string
  description = "The OCID of the existing VCN"
  default     = ""
}

variable "wls_vcn_cidr" {
  type        = string
  description = "The IPv4 CIDR block that will be assigned for the VCN"
  default     = ""
}

variable "use_existing_subnets" {
  type        = bool
  description = "Set to true if the existing subnets are used to create VCN"
  default     = false
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

variable "resource_name_prefix" {
  type        = string
  description = "Prefix which will be used to create VCN display name"
}
