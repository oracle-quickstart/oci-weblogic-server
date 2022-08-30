# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "user_id" {
  type        = string
  description = "The OCID of the user that is creating the WebLogic for OCI stack"
}

variable "fingerprint" {
  type        = string
  description = "The fingerprint of the public key added to the API Keys section of the OCI web console for the user creating the WebLogic for OCI stack"
}

variable "private_key_path" {
  type        = string
  description = "The path to the private key file in PEM format, that is the pair of the public key added to the API Keys section of the OCI web console for the user creating the WebLogic for OCI stack"
}

provider "oci" {
  tenancy_ocid     = var.tenancy_id
  user_ocid        = var.user_id
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

provider "oci" {
  alias                = "home"
  region               = local.home_region
  tenancy_ocid         = var.tenancy_id
  user_ocid            = var.user_id
  fingerprint          = var.fingerprint
  private_key_path     = var.private_key_path
  disable_auto_retries = true
}

