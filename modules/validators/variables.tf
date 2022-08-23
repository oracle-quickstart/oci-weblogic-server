# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "service_name" {
  type        = string
  description = "Prefix for stack resources"
}

variable "wls_ms_port" {
  type        = number
  description = "The managed server port for T3 protocol"
}

variable "wls_ms_ssl_port" {
  type        = number
  description = "The managed server port for T3s protocol"
}

variable "wls_extern_admin_port" {
  type        = number
  description = "The administration server port on which to access the administration console"
}

variable "wls_extern_ssl_admin_port" {
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

variable "add_load_balancer" {
  type        = bool
  description = "Set to true to add a load balancer"
}

variable "is_idcs_selected" {
  type        = bool
  description = "Indicates that idcs has to be provisioned"
}

variable "idcs_host" {
  type        = string
  description = "Value for idcs host"
}

variable "idcs_tenant" {
  type        = string
  description = "Value for idcs tenant"
}

variable "idcs_client_id" {
  type        = string
  description = "Value for idcs client id"
}

variable "idcs_client_secret_id" {
  type        = string
  description = "The OCID of the vault secret containing the password of the idcs client secret"
}

variable "idcs_cloudgate_port" {
  type        = number
  description = "Value for idcs cloud gate port"
}




