# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

# Variable used in UI only
variable "create_new_subnets" {
  type    = bool
  default = false
}

# Variable used in UI only
variable "create_new_vcn" {
  type    = bool
  default = false
}

variable "network_compartment_id" {
  type        = string
  description = "The OCID of the compartment for network resources. Leave it blank to use the the same compartment for both compute and network resources"
  default     = ""
}

# Variable used in UI only
variable "subnet_compartment_id" {
  type        = string
  description = "The OCID of the compartment for existing subnets"
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
  default     = ""
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
  default     = true
}

# Variable used in UI only
variable "load_balancer_strategy_new_subnet" {
  type        = string
  description = "Indicate if you cant to create a new load balancer or use an existing load balancer"
  default     = "Create New Load Balancer"
}

# Variable used in UI only
variable "load_balancer_strategy_existing_subnet" {
  type        = string
  description = "Indicate if you cant to create a new load balancer or use an existing load balancer"
  default     = "Create New Load Balancer"
}

variable "existing_load_balancer_id" {
  type        = string
  description = "The OCID of an existing load balancer. If set, use the existing load balancer and add the stack nodes to the backend set of the existing load balancer. Set add_load_balancer to true in order for this value to take effect"
  default     = ""
}

variable "backendset_name_for_existing_load_balancer" {
  type        = string
  default     = ""
  description = "Existing load balancer backend set name"
}

# Variable used in UI only
variable "add_lb_reserved_public_ip_id" {
  description = "Set to true to use a reserved public IP for load balancer"
  type        = bool
  default     = false
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

variable "existing_lb_nsg_id" {
  type        = string
  description = "The OCID of the pre-created NSG that should be attached to the load balancer"
  default     = ""
}

variable "mount_target_subnet_id" {
  type        = string
  description = "OCID for existing subnet for mount target"
  default     = ""
}

variable "mount_target_subnet_cidr" {
  type        = string
  description = "CIDR value of  the subnet to be used for FSS mount target"
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
  default     = ""
}

variable "wls_subnet_cidr" {
  type        = string
  description = "CIDR for weblogic subnet"
  default     = ""
}

variable "bastion_subnet_cidr" {
  type        = string
  description = "CIDR for bastion subnet"
  default     = ""
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

variable "add_existing_nsg" {
  type        = bool
  description = "Use an existing network security group"
  default     = false
}

variable "existing_admin_server_nsg_id" {
  type        = string
  description = "The OCID of the pre-created NSG that should be attached to the admin server"
  default     = ""
}

variable "existing_managed_server_nsg_id" {
  type        = string
  description = "The OCID of the pre-created NSG that should be attached to the managed server"
  default     = ""
}

variable "db_vcn_lpg_id" {
  type        = string
  description = "The OCID of the Local Peering Gateway (LPG) in the DB VCN to which the LPG in the WebLogic VCN will be peered. Required for VCN peering"
  default     = ""
}

variable "wait_time_wls_vnc_dns_resolver" {
  type        = number
  description = "The amount of seconds to wait before querying the DNS resolver association of the WebLogic VCN. Used by VCN peering module and ignored if using existing VCN"
  validation {
    condition     = var.wait_time_wls_vnc_dns_resolver > 0 && var.wait_time_wls_vnc_dns_resolver <= 600
    error_message = "WLSC-ERROR: The value for wait_time_wls_vnc_dns_resolver should be between 0 and 600 (10 minutes)."
  }
  default = 60
}

variable "skip_network_validation" {
  type = bool 
  description = "Used in case there is something really wrong with the validation and we need to skip it"
  default = true
}
