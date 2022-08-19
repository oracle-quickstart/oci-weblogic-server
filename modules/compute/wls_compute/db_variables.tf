# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "jrf_parameters" {
  type = object({
    db_user        = string
    db_password_id = string
    atp_db_parameters = object({
      atp_db_id    = string
      atp_db_level = string
    })
  })
  description = <<-EOT
  jrf_parameters = {
    db_user: "Name of the user that will connect to the database to create the schemas"
    db_password_id: "The OCID of a vault secret with the password of the database"
    atp_db_parameters = {
      atp_db_id: "The OCID of the ATP database"
      atp_db_level :  Allowed values are "low", "tp", "tpurgent"
    }
  }
  EOT
  default = {
    db_user        = ""
    db_password_id = ""
    atp_db_parameters = {
      atp_db_id    = ""
      atp_db_level = "low"
    }
  }
  validation {
    condition     = contains(["low", "tp", "tpurgent"], var.jrf_parameters.atp_db_parameters.atp_db_level)
    error_message = "Invalid value for atp_db_parameters.atp_db_level. Allowed values are low, tp and tpurgent."
  }
}

//Add security list to existing db vcn
variable "db_existing_vcn_add_seclist" {
  type = bool
  description = "Set to true to add a security list to the database subnet (for OCI DB) when using existing VCN or network security group (for ATP with private endpoint) that allows connections from the WebLogic Server subnet"
}