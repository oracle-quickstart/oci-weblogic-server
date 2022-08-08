
variable "compartment_id" {
  type        = string
  description = "The OCID of the compartment where the lb will be created"
  validation {
    condition     = length(regexall("^ocid1.compartment.*$", var.compartment_id)) > 0
    error_message = "The value for compartment_id should start with \"ocid1.compartment.\"."
  }
}

variable "add_load_balancer" {
  type        = bool
  description = "Set to true of a load balancer was created as part of the WebLogic for OCI stack"
}

variable "existing_load_balancer_id" {
  type        = string
  description = "The OCID of the existing load balancer"
}

variable "lb_name" {
  type        = string
  description = "A user-friendly load balancer name"
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

variable "add_lb_reserved_public_ip_id" {
  type        = bool
  description = "Whetehr Ocid of the pre-created public IP should be attached to this load balancer"
}

variable "lb_reserved_public_ip_id" {
  type        = string
  description = "Ocid of the pre-created public IP that should be attached to this load balancer"
}

variable "lb_subnet_2_id" {
  type        = list
  description = "An array of subnet OCIDs"
}

variable "lb_subnet_1_id" {
  type        = list
  description = "An array of subnet OCIDs"
}

variable "defined_tags" {
  type        = map
  default     = {}
  description = "Defined tags to be added to the compute instance"
}

variable "freeform_tags" {
  type        = map
  default     = {}
  description = "Free-form tags to be added to the compute instance"
}

