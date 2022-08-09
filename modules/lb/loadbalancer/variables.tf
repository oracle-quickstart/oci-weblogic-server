
variable "compartment_id" {
  type        = string
  description = "The OCID of the compartment where the lb will be created"
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
  description = "Defined tags and freeform tags to be added to the company instance"
  default = {
    defined_tags  = {},
    freeform_tags = {}
  }
}
