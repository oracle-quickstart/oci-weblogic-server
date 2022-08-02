variable "tenancy_id" {
  type = string
  description = "The OCID of the tenancy where the dynamic group and policy will be created"
}

variable "compartment_id" {
  type = string
  description = "The OCID of the compartment for the matching rule of dynamic group"
}

variable "service_name" {
  type        = string
  description = "Prefix to be added to the policy"
}

variable "create_policies" {
  type    = bool
  description = "Set to true if you want to create policies"
  default = true
}

variable "defined_tags" {
  type    = map
  description = "Defined tags to be added to the policy"
  default = {}
}

variable "freeform_tags" {
  type    = map
  description = "Free-form tags to be added to the policy"
  default = {}
}

# TODO Add dynamic_group_rule
#variable "dynamic_group_rule" {
#  type = string
#  description = "value of the tag to identify resources"
#}

