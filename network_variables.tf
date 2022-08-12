variable "network_compartment_id" {
  type    = string
  description = "The OCID of the compartment for network resources. Leave it blank to use the the same compartment for both compute and network resources"
  default = ""
}

variable "wls_vcn_cidr" {
  type        = string
  description = "The CIDR of the VCN where the compute instance will be created"
}

variable "use_regional_subnet" {
  type        = bool
  description = "Indicates use of regional subnets (preferred) instead of AD specific subnets"
  default     = true
}

variable "wls_subnet_id" {
  type = string
  description = "The OCID of the subnet for the WebLogic instances. Leave it blank if a new subnet will be created by the stack"
  default     = ""
}

variable "bastion_subnet_id" {
  type = string
  description = "The OCID of the subnet for the bastion instance"
  default     = ""

}

variable "wls_availability_domain_name" {
  type        = string
  description = "Availability domain for WebLogic compute instances"
  default     = ""
}

variable "assign_weblogic_public_ip" {
  type        = bool
  description = "Set to true if the WebLogic compute instances will be created in a public subnet and should have a public IP"
  default     = false
}

variable "add_load_balancer" {
  type        = bool
  description = "If this variable is true and existing_load_balancer is blank, a new load balancer will be created for the stack. If existing_load_balancer_id is not blank, the specified load balancer will be used"
  default     = false
}

variable "existing_load_balancer_id" {
  type        = string
  description = "The OCID of an existing load balancer. If set, use the existing load balancer and add the stack nodes to the backend set of the existing load balancer. Set add_load_balancer to true in order for this value to take effect"
  default     = ""
}

variable "lb_reserved_public_ip_id" {
  type        = string
  description = "The OCID of a reserved public IP for the load balancer of the stack"
  default     = ""
}

variable "is_lb_private" {
  type        = bool
  description = "Indicates use of private load balancer"
  default     = false
}


variable "lb_max_bandwidth" {
  type        = number
  description = "Maximum bandwidth for the load balancer (in Mbps)"
  default     = 400
}

variable "lb_min_bandwidth" {
  type        = number
  description = "Minimum bandwidth for the load balancer (in Mbps)"
  default     = 10
}

variable "lb_subnet_1_id" {
  type = string
  description = "The OCID of a regional or AD-specific subnet for primary load balancer"
  default     = ""
}

variable "lb_subnet_2_id" {
  type = string
  description = "The OCID of a regional or AD-specific subnet for secondary load balancer"
  default     = ""
}
