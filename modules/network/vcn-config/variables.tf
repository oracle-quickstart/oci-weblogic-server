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
  description = "The OCID of the VCN the route table belongs to"
}

variable "wls_vcn_name" {
  type        = string
  description = "A user-friendly VCN name"
}

variable "existing_vcn_id" {
  type        = string
  description = "The OCID of the existing VCN"
}

variable "add_load_balancer" {
  type    = bool
  default = false
}

// Optional params

variable "dhcp_options_name" {
  default = "dhcpOptions"
}

variable "route_table_name" {
  default = "routetable"
}

variable "is_lb_private" {
}

variable "wls_expose_admin_port" {
  type = bool
}

variable "wls_admin_port_source_cidr" {
}

// Optional params

/*
Allow access to all ports to all VMs on the specified subnet CIDR
For LB backend subnet - an lb_additional_subnet_cidr will be = LB frontend subnet CIDR
This will open ports for LB backend subnet VMs to all VMs in its subnet and
in LB frontend subnet.

For LB frontend subnet - this is not passed.
*/

variable "wls_subnet_cidr" {}

variable "lb_subnet_1_cidr" {}

variable "lb_subnet_2_cidr" {}

// Optional params
variable "wls_admin_port" {
  default = "7001"
}

variable "wls_ssl_admin_port" {
  default = "7002"
}

variable "wls_ms_port" {
  default = "7003"
}

variable "wls_ms_ssl_port" {
  default = "7004"
}

variable "wls_security_list_name" {
  default = "wls-security-list"
}

variable "use_existing_subnets" {
  default = false
}

variable "service_name_prefix" {}

variable "nat_gateway_display_name" {
  default = "nat-gateway"
}

variable "assign_backend_public_ip" {
  default = true
}

variable "use_regional_subnets" {
  type    = bool
  default = false
}

variable "wls_bastion_security_list_name" {
  default = "wls-bastion-security-list"
}

variable "bastion_subnet_cidr" {
  default = ""
}

variable "is_bastion_instance_required" {
  type = bool
}

variable "existing_bastion_instance_id" {
  type = string
}

variable "is_single_ad_region" {}

variable "is_idcs_selected" {
  type = bool
}

variable "idcs_cloudgate_port" {}

variable "is_vcn_peering" {}

variable "defined_tags" {
  type    = map
  default = {}
}

variable "freeform_tags" {
  type    = map
  default = {}
}

variable "appdb_vcn_peering" {
  type    = bool
  default = false
}

variable "existing_mt_subnet_id" {
  type = string
}

variable "add_fss" {
  type = bool
}

variable "vcn_cidr" {
  type = string
}

variable "oci_identity_tag_ns_id" {
  type = string
}
