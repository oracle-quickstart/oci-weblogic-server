# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "compartment_id" {
  type        = string
  description = "The OCID of the compartment where the vcn config will be created"
  validation {
    condition     = length(regexall("^ocid1.compartment.*$", var.compartment_id)) > 0
    error_message = "WLSC-ERROR: The value for compartment_id should start with \"ocid1.compartment.\"."
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

// Optional params

variable "dhcp_options_name" {
  type        = string
  description = "A user-friendly name of the DHCP options in a VCN"
  default     = "dhcpOptions"

}

variable "route_table_name" {
  type        = string
  description = "A user-friendly name of the route table"
  default     = "routetable"
}

variable "wls_expose_admin_port" {
  type        = bool
  description = "Set to true if you want to export wls admin port"
  default     = false
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

variable "wls_security_list_name" {
  type        = string
  description = "A user-friendly name of the compute instance seclist"
  default     = "wls-security-list"
}

variable "resource_name_prefix" {
  type        = string
  description = "Prefix which will be used to create VCN config display name"
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

variable "existing_mt_subnet_id" {
  type        = string
  description = "The OCID of the existing mount target subnet id"
  default     = ""
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

variable "wls_ms_source_cidrs" {
  type        = list(any)
  description = "The Weblogic managed servers source CIDR values"
}

variable "existing_service_gateway_ids" {
  type        = list(any)
  description = "The service gateway OCID value if existing vcn is used"
  default     = []
}

variable "existing_nat_gateway_ids" {
  type        = list(any)
  description = "The nat gateway OCID values"
}

variable "create_nat_gateway" {
  type        = bool
  description = "Set to true if nat gateway needs to be created"
  default     = false
}

variable "create_service_gateway" {
  type        = bool
  description = "Set to true if service gateway needs to be created"
  default     = false
}

variable "create_internet_gateway" {
  type        = bool
  description = "Set to true if internet gateway needs to be created"
  default     = false
}

variable "lb_destination_cidr" {
  type        = string
  description = "Set to bastion subnet cidr if loadbalancer is set to private"
}

variable "create_load_balancer" {
  type        = bool
  description = "Set to true if add load balancer is true"
}

variable "load_balancer_min_value" {
  type        = number
  description = "The managed server port or the managed server SSL port on which to send application traffic"
  default     = 7003
}

variable "load_balancer_max_value" {
  type        = number
  description = "The managed server port or the managed server SSL port on which to send application traffic"
  default     = 7004
}

variable "nsg_ids" {
  type = map(any)
  description = "A map of nsg ids for load balancer,bastion,fss,admin server instance, and managed server instance"
  default = {
    lb_nsg_id  = ""
    bastion_nsg_id = ""
    mount_target_nsg_id = ""
    admin_nsg_id = ""
    managed_nsg_id = ""
  }
}
