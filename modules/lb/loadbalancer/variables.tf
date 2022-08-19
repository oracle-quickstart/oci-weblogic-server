# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "compartment_id" {
  type        = string
  description = "The OCID of the compartment where the load balancer will be created"
  validation {
    condition     = length(regexall("^ocid1.compartment.*$", var.compartment_id)) > 0
    error_message = "The value for compartment_id should start with \"ocid1.compartment.\"."
  }
}

variable "lb_name" {
  type        = string
  description = "A user-friendly load balancer name"
}

variable "lb_shape" {
  type        = string
  description = "Load balancer shape"
  default     = "flexible"
}

variable "lb_max_bandwidth" {
  type        = number
  description = "Bandwidth in Mbps that determines the maximum bandwidth (ingress plus egress) that the load balancer can achieve"
}

variable "lb_min_bandwidth" {
  type        = number
  description = "Bandwidth in Mbps that determines the total pre-provisioned bandwidth"
}

variable "is_lb_private" {
  type        = bool
  description = "Whether the load balancer has a VCN-local (private) IP address"
}

variable "lb_reserved_public_ip_id" {
  type        = list(any)
  description = "The list of OCIDs of the pre-created public IP that should be attached to this load balancer"
  default     = []
  validation {
    condition     = length(var.lb_reserved_public_ip_id) == 0 || length(var.lb_reserved_public_ip_id) == 1
    error_message = "The lb reserved public ip id value should be zero or one."
  }
}

variable "lb_subnet_2_id" {
  type        = list(any)
  description = "An array of subnet OCIDs"
}

variable "lb_subnet_1_id" {
  type        = list(any)
  description = "An array of subnet OCIDs"
}

variable "tags" {
  type = object({
    defined_tags  = map(any),
    freeform_tags = map(any)
  })
  description = "Defined tags and freeform tags to be added to the load balancer"
  default = {
    defined_tags  = {},
    freeform_tags = {}
  }
}
