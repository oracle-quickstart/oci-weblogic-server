# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "is_idcs_selected" {
  type        = bool
  description = "Indicates that Oracle Identity Cloud Service (IDCS) is used to authenticate user. If not selected, WebLogic Server uses the local identity store."
  default     = false
}

variable "idcs_host" {
  type        = string
  description = "The domain name for the host that you use to access Identity Cloud Service"
  default     = "identity.oraclecloud.com"
}

variable "idcs_port" {
  type        = number
  description = "The port number that you use to access Identity Cloud Service"
  default     = 443
}

variable "idcs_tenant" {
  type        = string
  description = "The ID of your Identity Cloud Service tenant, which typically has the format idcs-<guid>, and is part of the host name that you use to access Identity Cloud Service"
  default     = ""
}

variable "idcs_client_id" {
  type        = string
  description = "The client ID of a confidential application in Identity Cloud Service that is used to create the necessary artifacts in Identity Cloud Service. This application needs to be configured as client, and has to be granted with access to Identity Cloud Service Admin APIs, with Identity Domain Administrator app role."
  default     = ""
}

variable "idcs_client_secret_id" {
  type        = string
  description = "The OCID of the vault secret containing the confidential application password in IDCS"
  default     = ""
}

variable "idcs_cloudgate_port" {
  type        = number
  description = "The listen port for the Identity Cloud Service App Gateway, which authenticates requests and redirects them to WebLogic Server"
  default     = 9999
}
