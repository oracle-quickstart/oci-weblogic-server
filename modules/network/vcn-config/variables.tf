# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "compartment_id" {
  type        = string
  description = "The OCID of the compartment where the vcn config will be created"
  validation {
    condition     = length(regexall("^ocid1.compartment.*$", var.compartment_id)) > 0
    error_message = "The value for compartment_id should start with \"ocid1.compartment.\"."
  }
}

variable "internet_gateway_destination" {
  type        = string
  description = "The range of IP addresses used for matching when routing traffic"
  default     = "0.0.0.0/0"
}

variable "vcn_id" {
  type        = string
  description = "The OCID of the new VCN or existing VCN"
}

variable "wls_vcn_name" {
  type        = string
  description = "A user-friendly name of the VCN"
}

variable "add_load_balancer" {
  type        = bool
  description = "Set to true if ypu want loadbalancer"
  default     = false
}

// Optional params

variable "dhcp_options_name" {
  default     = "dhcpOptions"
  description = "A user-friendly name of the DHCP options in a VCN"
}

variable "route_table_name" {
  type        = string
  description = "A user-friendly name of the route table"
  default     = "routetable"
}

variable "is_lb_private" {
  type        = bool
  description = "Set to true if you want private loadbalancer"
}

variable "wls_expose_admin_port" {
  type        = bool
  description = "Set to true if you want to export wls admin port"
}

variable "wls_admin_port_source_cidr" {
  type        = string
  description = "The CIDR value of the wls admin source port"
}

// Optional params

/*
Allow access to all ports to all VMs on the specified subnet CIDR
For LB backend subnet - an lb_additional_subnet_cidr will be = LB frontend subnet CIDR
This will open ports for LB backend subnet VMs to all VMs in its subnet and
in LB frontend subnet.

For LB frontend subnet - this is not passed.
*/

variable "wls_subnet_cidr" {
  type        = string
  description = "The CIDR value of the wls subnet"
}

variable "lb_subnet_1_cidr" {
  type        = string
  description = "The CIDR value of the loadbalancer subnet 1"
}

variable "lb_subnet_2_cidr" {
  type        = string
  description = "The CIDR value of the loadbalancer subnet 2"
}

// Optional params
variable "wls_extern_admin_port" {
  type        = number
  description = "The administration server port on which to access the administration console"
  default     = 7001
}

variable "wls_extern_ssl_admin_port" {
  type        = number
  description = "The administration server SSL port on which to access the administration console"
  default     = 7002
}

variable "wls_ms_extern_port" {
  type        = number
  description = "The managed server port on which to send application traffic"
  default     = 7003
}

variable "wls_ms_extern_ssl_port" {
  type        = number
  description = "The managed server SSL port on which to send application traffic"
  default     = 7004
}

variable "wls_security_list_name" {
  type        = string
  description = "A user-friendly name of the compute instance seclist"
  default     = "wls-security-list"
}

variable "resource_name_prefix" {
  type        = string
  description = "Prefix which will be used to create VCN config display name"
}

variable "assign_backend_public_ip" {
  type        = bool
  description = "Set to true if loadbalancer backened needs to be assigned public ip"
  default     = true
}

variable "use_regional_subnets" {
  type        = bool
  description = "Set to true if regional subnets to be used"
  default     = false
}

variable "wls_bastion_security_list_name" {
  type        = string
  description = "A user-friendly name of the bastion instance seclist"
  default     = "wls-bastion-security-list"
}

variable "bastion_subnet_cidr" {
  type        = string
  description = "The CIDR value of the bastion subnet"
  default     = ""
}

variable "is_bastion_instance_required" {
  type        = bool
  description = "Whether bastion instance is required to connect to the compute instance"
  default     = true
}

variable "existing_bastion_instance_id" {
  type        = string
  description = "An OCID of the existing bastion instance to connect to the compute instance"
}

variable "is_single_ad_region" {
  type        = bool
  description = "Set to true if you want single AD region"
}

variable "is_vcn_peering" {
  type        = bool
  description = "Set to true if you want VCN peering"
  default     = false
}

variable "tags" {
  type = object({
    defined_tags  = map(any),
    freeform_tags = map(any),
  })
  description = "Defined tags and freeform tags to be added to the VCN config"
  default = {
    defined_tags  = {},
    freeform_tags = {},
  }
}

variable "appdb_vcn_peering" {
  type        = bool
  description = "Set to true if you want appdb VCN peering"
  default     = false
}

variable "existing_mt_subnet_id" {
  type        = string
  description = "The OCID of the exisitng mount target subnet id"
}

variable "add_fss" {
  type        = bool
  description = "Set to true if you want FSS to be assigned to the VCN"
  default     = false
}

variable "vcn_cidr" {
  type        = string
  description = "The range of IP addresses that a packet originating from the instance can go to"
}

variable "wls_ms_content_port" {
  type        = number
  description = "The managed server SSL port  or idcs cloudgate port which allows public internet traffic"
}
