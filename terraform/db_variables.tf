# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "oci_db_connection_string" {
  type        = string
  description = "Oracle database connection string to connect to database. Example: //<scan_hostname>.<host_domain_name>:<db_port>/<pdb_or_sid>.<Host Domain Name>"
  default     = ""
}

variable "oci_db_user" {
  type        = string
  description = "The user name used to connect to the OCI database"
  default     = ""

}

variable "oci_db_password_id" {
  type        = string
  description = "The OCID of the vault secret with the password for the OCI database"
  default     = ""
}

variable "oci_db_port" {
  type        = number
  description = "The listener port for the OCI database"
  default     = 1521
}

variable "oci_db_compartment_id" {
  type        = string
  description = "The OCID of the compartment of the OCI database"
  default     = ""
}

variable "oci_db_network_compartment_id" {
  type        = string
  description = "The OCID of the compartment in which the DB System VCN is found"
  default     = ""
}

variable "oci_db_dbsystem_id" {
  type        = string
  description = "The OCID of the OCI database system"
  default     = ""
}

variable "oci_db_database_id" {
  type        = string
  description = "The OCID of the OCI database"
  default     = ""
}

variable "oci_db_pdb_service_name" {
  type        = string
  description = "The name of the pluggable database (PDB) in which to provision the schemas for a JRF-enabled WebLogic Server domain. This is required for Oracle Database 12c or later"
  default     = ""
}

variable "oci_db_existing_vcn_id" {
  type        = string
  description = "The OCID of the VCN used by the OCI database"
  default     = ""
}

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
    error_message = "WLSC-ERROR: Invalid value for atp_db_level. Allowed values are low, tp and tpurgent."
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