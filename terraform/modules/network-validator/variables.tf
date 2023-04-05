# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "wls_subnet_id" {
  type        = string
  description = "The OCID of the subnet where WebLogic VMs will be created"
}

variable "bastion_subnet_id" {
  type        = string
  description = "The OCID of the subnet for the bastion instance"
}

variable "bastion_ip" {
  type        = string
  description = "Bastion Host IP of the existing bastion"
}

variable "lb_subnet_1_id" {
  type        = string
  description = "The OCID of a regional or AD-specific subnet for primary load balancer"
}

variable "lb_subnet_2_id" {
  type        = string
  description = "The OCID of a AD-specific subnet for secondary load balancer"
}

variable "mount_target_subnet_id" {
  type        = string
  description = "The OCID for existing subnet for mount target"
}

variable "atp_db_id" {
  type        = string
  description = "The OCID of the ATP database"
}

variable "oci_db_dbsystem_id" {
  type        = string
  description = "The OCID of the OCI database system"
}

variable "oci_db_port" {
  type        = number
  description = "The listener port for the OCI database"
}

variable "wls_extern_admin_port" {
  type        = number
  description = "WebLogic console port"
}

variable "wls_extern_ssl_admin_port" {
  type        = number
  description = "The administration server SSL port on which to access the administration console"
}

variable "wls_ms_extern_port" {
  type        = number
  description = "The managed server port on which to send application traffic"
}

variable "existing_admin_server_nsg_id" {
  type        = string
  description = "The OCID of the pre-created NSG that should be attached to the admin server"
}

variable "existing_managed_server_nsg_id" {
  type        = string
  description = "The OCID of the pre-created NSG that should be attached to the managed server"
}

variable "existing_lb_nsg_id" {
  type        = string
  description = "The OCID of the pre-created NSG that should be attached to the load balancer"
}

variable "existing_mount_target_nsg_id" {
  type        = string
  description = "The OCID of the pre-created NSG that should be attached to the mount target"
}

variable "existing_bastion_nsg_id" {
  type        = string
  description = "The OCID of the pre-created NSG that should be attached to the bastion instance"
}

variable "lb_source_cidr" {
  type        = string
  description = "Set to empty value if loadbalancer is set to private"
}
