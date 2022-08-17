# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "atp_db_id" {
  type        = string
  description = "The OCID of the ATP database"
  default     = ""
}

variable "atp_db_compartment_id" {
  type        = string
  description = "The OCID of the compartment where the ATP database is located"
  default     = ""
}

variable "atp_db_level" {
  type        = string
  description = "The ATP database level. Allowed values are low, tp, tpurgent"
  default     = "low"
  validation {
    condition     = contains(["low", "tp", "tpurgent"], var.atp_db_level)
    error_message = "Invalid value for atp_db_level. Allowed values are low, tp and tpurgent."
  }
}

variable "atp_db_password_id" {
  type        = string
  description = "The OCID of the vault secret containing the password for the ATP database"
  default     = ""
}

#This variable is used for both oci db and ATP with private subnet
#NOTE: this has not been renamed to support future cloning support
variable "ocidb_existing_vcn_add_seclist" {
  type        = bool
  description = "Set to true to add a security list to the database subnet (for OCI DB) when using existing VCN or network security group (for ATP with private endpoint) that allows connections from the WebLogic Server subnet"
  default     = true
}