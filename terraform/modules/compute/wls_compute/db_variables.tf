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
    oci_db_parameters = object({
      oci_db_connection_string      = string
      oci_db_compartment_id         = string
      oci_db_dbsystem_id            = string
      oci_db_database_id            = string
      oci_db_pdb_service_name       = string
      oci_db_port                   = number
      oci_db_network_compartment_id = string
      oci_db_existing_vcn_id        = string
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
    oci_db_parameters = {
      oci_db_connection_string: "Oracle database connection string to connect to database. Example: //<scan_hostname>.<host_domain_name>:<db_port>/<pdb_or_sid>.<Host Domain Name>
      oci_db_compartment_id: "The compartment in which the DB System is found"
      oci_db_dbsystem_id: "The Oracle Cloud Infrastructure DB System to use for this WebLogic Server domain"
      oci_db_database_id: "The database within the DB System in which to provision the schemas for a JRF-enabled WebLogic Server domain"
      oci_db_pdb_service_name: "The name of the pluggable database (PDB) in which to provision the schemas for a JRF-enabled WebLogic Server domain. This is required for Oracle Database 12c or later"
      oci_db_port: "The Listener Port for the Database"
      oci_db_network_compartment_id: "The compartment in which the DB System Virtual Cloud Network is found"
      oci_db_existing_vcn_id: "An existing Virtual Cloud Network (VCN) used by DB System. If the selected VCN is different from WebLogic Server VCN then local VCN peering is needed."
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
    oci_db_parameters = {
      oci_db_connection_string      = ""
      oci_db_compartment_id         = ""
      oci_db_dbsystem_id            = ""
      oci_db_database_id            = ""
      oci_db_database_id            = ""
      oci_db_pdb_service_name       = ""
      oci_db_port                   = 1521
      oci_db_network_compartment_id = ""
      oci_db_existing_vcn_id        = ""
    }
  }
  validation {
    condition     = contains(["low", "tp", "tpurgent"], var.jrf_parameters.atp_db_parameters.atp_db_level)
    error_message = "WLSC-ERROR: Invalid value for atp_db_parameters.atp_db_level. Allowed values are low, tp and tpurgent."
  }
}

//Add security list to existing db vcn
variable "db_existing_vcn_add_seclist" {
  type        = bool
  description = "Set to true to add a security list to the database subnet (for OCI DB) or a security rule to the network security group (for ATP with private endpoint) that allows connections from the WebLogic Server subnet"
}