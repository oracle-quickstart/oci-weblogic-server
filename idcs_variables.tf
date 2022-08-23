# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "is_idcs_selected" {
  type        = bool
  description = "Indicates that idcs has to be provisioned"
  default     = false
}

variable "idcs_host" {
  type        = string
  description = "value for idcs host"
  default     = "identity.oraclecloud.com"
}

variable "idcs_port" {
  type        = number
  description = "value for idcs port"
  default     = 443
}

variable "idcs_tenant" {
  type        = string
  description = "value for idcs tenant"
  default     = ""
}

variable "idcs_client_id" {
  type        = string
  description = "value for idcs client id"
  default     = ""
}

variable "idcs_client_secret_id" {
  type        = string
  description = "The OCID of the vault secret containing the password for for idcs client secret"
  default     = ""
}

variable "idcs_cloudgate_port" {
  type        = number
  description = "value for idcs cloud gate port"
  default     = 9999
}
