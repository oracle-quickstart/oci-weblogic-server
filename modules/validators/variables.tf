# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable original_service_name {
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
  type = string
  description = "Create a security list to allow access to the WebLogic Administration Console port to the source CIDR range. [WARNING] Keeping the default 0.0.0.0/0 CIDR will expose the console to the internet. You should change the CIDR range to allow access to a trusted IP range."
}

variable "wls_expose_admin_port" {
  type = bool
  description = "[WARNING] Selecting this option will expose the console to the internet if the default 0.0.0.0/0 CIDR is used. You should change the CIDR range below to allow access to a trusted IP range."
}




