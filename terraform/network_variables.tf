# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "network_compartment_id" {
  type        = string
  description = "The OCID of the compartment for network resources. Leave it blank to use the the same compartment for both compute and network resources"
  default     = ""
}

variable "wls_existing_vcn_id" {
  type        = string
  description = "The OCID of the existing VCN where the WebLogic servers and other resources will be created. If not specified, a new VCN is created"
  default     = ""
}

variable "wls_vcn_cidr" {
  type        = string
  description = "The CIDR of the VCN where the compute instance will be created"
  default     = "10.0.0.0/16"
}

variable "wls_vcn_name" {
  type        = string
  description = "Name of new virtual cloud network"
  default     = ""
}

variable "use_regional_subnet" {
  type        = bool
  description = "Indicates use of regional subnets (preferred) instead of AD specific subnets"
  default     = true
}

variable "wls_subnet_id" {
  type        = string
  description = "The OCID of the subnet for the WebLogic instances. Leave it blank if a new subnet will be created by the stack"
  default     = ""
}

variable "bastion_subnet_id" {
  type        = string
  description = "The OCID of the subnet for the bastion instance"
  default     = ""
}

variable "bastion_subnet_name" {
  type        = string
  description = "A user-friendly bastion subnet name"
  default     = "bsubnet"
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
  type        = string
  description = "The OCID of a regional or AD-specific subnet for primary load balancer"
  default     = ""
}

variable "lb_subnet_2_id" {
  type        = string
  description = "The OCID of a regional or AD-specific subnet for secondary load balancer"
  default     = ""
}

variable "use_existing_subnets" {
  type        = bool
  description = "Set to true if the exsiting subnets are used to create VCN config"
  default     = false
}

variable "mount_target_subnet_id" {
  type        = string
  description = "OCID for existing subnet for mount target"
  default     = ""
}

variable "lb_subnet_1_name" {
  type        = string
  description = "OCID for loadbalancer subnet"
  default     = "lb-sbnet-1"
}

variable "lb_subnet_2_name" {
  type        = string
  description = "OCID for loadbalancer subnet"
  default     = "lb-sbnet-2"
}

variable "lb_subnet_1_cidr" {
  type        = string
  description = "CIDR for loadbalancer subnet"
  default     = "10.0.4.0/16"
}

variable "lb_subnet_2_cidr" {
  type        = string
  description = "CIDR for loadbalancer subnet"
  default     = "10.0.5.0/16"
}

variable "wls_subnet_cidr" {
  type        = string
  description = "CIDR for weblogic subnet"
  default     = "10.0.3.0/16"
}

variable "bastion_subnet_cidr" {
  type        = string
  description = "CIDR for bastion subnet"
  default     = "10.0.6.0/16"
}

# Used in UI instead of use_regional_subnet
variable "subnet_span" {
  type        = string
  description = "subnet type to be used"
  default     = "Regional Subnet"
}

# Used in UI instead of assign_weblogic_public_ip
variable "subnet_type" {
  type        = string
  description = "Private subnet or Public subnet type"
  default     = "Use Private Subnet"
}

variable "wls_subnet_name" {
  type        = string
  description = "A user-friendly subnet name"
  default     = "wl-subnet"
}
