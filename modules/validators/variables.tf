# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable service_name {
  type        = string
  description = "Prefix for stack resources"
}

variable wls_ms_port {
  type        = number
  description = "The managed server port for T3 protocol"
}

variable wls_ms_ssl_port {
  type        = number
  description = "The managed server port for T3s protocol"
}

variable wls_extern_admin_port {
  type        = number
  description = "The administration server port on which to access the administration console"
}

variable wls_extern_ssl_admin_port {
  type        = number
  description = "The administration server SSL port on which to access the administration console"
}

variable "wls_admin_port_source_cidr" {
  type        = string
  description = "Create a security list to allow access to the WebLogic Administration Console port to the source CIDR range. [WARNING] Keeping the default 0.0.0.0/0 CIDR will expose the console to the internet. You should change the CIDR range to allow access to a trusted IP range."
}

variable "wls_expose_admin_port" {
  type        = bool
  description = "[WARNING] Selecting this option will expose the console to the internet if the default 0.0.0.0/0 CIDR is used. You should change the CIDR range below to allow access to a trusted IP range."
}

variable "wls_subnet_cidr" {
  type = string
  description = "CIDR for weblogic subnet"
}

variable "is_bastion_instance_required" {
  type        = bool
  description = "Set to true to use a bastion, either new or existing. If existing_bastion_instance_id is blank, a new bastion will be created"
}

variable "bastion_subnet_cidr" {
  type        = string
  description = "CIDR for bastion subnet"
}

variable "existing_bastion_instance_id" {
  type        = string
  description = "The OCID of a compute instance that will work as bastion"
}

variable "lb_subnet_1_cidr" {
  type        = string
  description = "CIDR for loadbalancer subnet"
}

variable "lb_subnet_2_cidr" {
  type        = string
  description = "CIDR for loadbalancer subnet"
}

variable "existing_vcn_id" {
  type        = string
  description = "The OCID of the existing VCN where the WebLogic servers and other resources will be created. If not specified, a new VCN is created"
}

variable "wls_subnet_id" {
  type        = string
  description = "The OCID of the subnet for the WebLogic instances. Leave it blank if a new subnet will be created by the stack"
}

variable "add_load_balancer" {
  type        = bool
  description = "If this variable is true and existing_load_balancer is blank, a new load balancer will be created for the stack. If existing_load_balancer_id is not blank, the specified load balancer will be used"
}

variable "existing_load_balancer_id" {
  type        = string
  description = "The OCID of an existing load balancer. If set, use the existing load balancer and add the stack nodes to the backend set of the existing load balancer. Set add_load_balancer to true in order for this value to take effect"
}

variable "lb_subnet_1_id" {
  type        = string
  description = "The OCID of a regional or AD-specific subnet for primary load balancer"
}

variable "lb_subnet_2_id" {
  type        = string
  description = "The OCID of a regional or AD-specific subnet for secondary load balancer"
}

variable "assign_public_ip" {
  type        = bool
  description = "Set to true if the WebLogic compute instances will be created in a public subnet and should have a public IP"
}

variable "bastion_subnet_id" {
  type        = string
  description = "The OCID of the subnet for the bastion instance"
}

variable "use_regional_subnet" {
  type        = bool
  description = "Indicates use of regional subnets (preferred) instead of AD specific subnets"
}

variable "vcn_name" {
  type        = string
  description = "Name of new virtual cloud network"
}

variable "bastion_ssh_private_key" {
  type        = string
  description = "Private ssh key for existing bastion instance"
}

variable "is_lb_private" {
  type        = bool
  description = "Indicates use of private load balancer"
}
