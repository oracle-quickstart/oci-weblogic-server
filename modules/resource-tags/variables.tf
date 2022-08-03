
variable "compartment_id" {
  type = string
  description = "The OCID of the compartment where the resource tags will be created"
}

variable "service_name" {
  type = string
  description = "Service name used by the WebLogic for OCI instance"
}

variable "is_system_tag" {
  type = bool
  description = "Create freeform tags for the OCI resources"
}

variable "create_dg_tags" {
  type = bool
  description = "Create tags for dynamic groups"
}
