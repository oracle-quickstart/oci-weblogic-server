# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {

  has_oci_db_compartment_id = trimspace(var.oci_db_compartment_id) != ""
  has_oci_db_dbsystem_id    = trimspace(var.oci_db_dbsystem_id) != ""
  has_oci_db_database_id    = var.oci_db_database_id != ""

  has_oci_db_pdb_service_name = var.oci_db_pdb_service_name != ""

  has_oci_db_user     = var.db_user != ""
  has_oci_db_password = var.db_password_id != ""

  # oci db required params
  missing_oci_db_user           = (var.is_oci_db || var.oci_db_connection_string != "") && !local.has_oci_db_user
  missing_oci_db_password       = (var.is_oci_db || var.oci_db_connection_string != "") && !local.has_oci_db_password
  missing_oci_db_compartment_id = (var.is_oci_db && !local.has_oci_db_compartment_id)
  missing_oci_db_database_id    = (var.is_oci_db && !local.has_oci_db_database_id)

  missing_oci_db_pdb_service_name = (var.is_oci_db && !local.has_oci_db_pdb_service_name)

  missing_oci_db_vcn_id = (var.is_oci_db && var.oci_db_existing_vcn_id == "")

  missing_oci_db_user_msg      = "WLSC-ERROR: The value for [db_user] is required."
  validate_missing_oci_db_user = local.missing_oci_db_user ? local.validators_msg_map[local.missing_oci_db_user_msg] : null

  missing_oci_db_password_msg      = "WLSC-ERROR: The value for [db_password] is required."
  validate_missing_oci_db_password = local.missing_oci_db_password ? local.validators_msg_map[local.missing_oci_db_password_msg] : null

  missing_oci_db_compartment_id_msg      = "WLSC-ERROR: The value for [oci_db_compartment_id] is required."
  validate_missing_oci_db_compartment_id = local.missing_oci_db_compartment_id ? local.validators_msg_map[local.missing_oci_db_compartment_id_msg] : null

  missing_oci_db_database_id_msg      = "WLSC-ERROR: The value for [oci_db_database_id] is required."
  validate_missing_oci_db_database_id = local.missing_oci_db_database_id ? local.validators_msg_map[local.missing_oci_db_database_id_msg] : null

  invalid_oci_db_password_msg = "WLSC-ERROR: The value for DB System Admin Password [db_password_id] is not valid. The value must begin with ocid1 followed by resource type, e.g. ocid1.vaultsecret."
  validate_oci_db_password    = (var.is_oci_db || var.oci_db_connection_string != "") && var.db_password_id != "" ? length(regexall("^ocid1.vaultsecret.", var.db_password_id)) > 0 ? null : local.validators_msg_map[local.invalid_oci_db_password_msg] : null

  missing_oci_db_vcn_id_msg      = "WLSC-ERROR: The value for [oci_db_existing_vcn_id] is required."
  validate_missing_oci_db_vcn_id = local.missing_oci_db_vcn_id ? local.validators_msg_map[local.missing_oci_db_vcn_id_msg] : null

  missing_vcn_id_with_oci_db_connect_string_use           = "WLSC-ERROR: Existing VCN Id [existing_vcn_id] is required when database connection string is required."
  validiate_missing_vcn_id_with_oci_db_connect_string_use = var.existing_vcn_id == "" && var.oci_db_connection_string != "" ? local.validators_msg_map[local.missing_vcn_id_with_oci_db_connect_string_use] : null

  //CLI validations
  invalid_oci_db_connect_msg  = "WLSC-ERROR:  Invalid database connection string. The value must start with //."
  valid_oci_db_connect_str    = var.oci_db_connection_string == "" || length(regexall("^(//)", var.oci_db_connection_string)) > 0
  validate_oci_db_connect_str = local.valid_oci_db_connect_str ? null : local.validators_msg_map[local.invalid_oci_db_connect_msg]

  invalid_oci_db_connect_msg_use_1  = "WLSC-ERROR: Either the value of database system id [oci_db_dbsystem_id] or connection string [oci_db_connection_string] can be provided."
  validate_oci_db_connect_str_use_1 = var.oci_db_connection_string != "" && local.has_oci_db_dbsystem_id ? local.validators_msg_map[local.invalid_oci_db_connect_msg_use_1] : null

  invalid_oci_db_connect_msg_use_2  = "WLSC-ERROR: Either the value of database id [oci_db_database_id] or connection string [oci_db_connection_string] can be provided."
  validate_oci_db_connect_str_use_2 = var.oci_db_connection_string != "" && local.has_oci_db_database_id ? local.validators_msg_map[local.invalid_oci_db_connect_msg_use_2] : null

  invalid_oci_db_connect_msg_use_3  = "WLSC-ERROR: The value of database connection string [oci_db_connection_string] can be provided only with existing vcn [wls_existing_vcn_id]."
  validate_oci_db_connect_str_use_3 = var.oci_db_connection_string != "" && var.existing_vcn_id == "" ? local.validators_msg_map[local.invalid_oci_db_connect_msg_use_3] : null

  invalid_oci_db_connect_msg_use_4  = "WLSC-ERROR: The value of database connection string [oci_db_connection_string] can be provided only for WebLogic 12c versions [wls_version]."
  validate_oci_db_connect_str_use_4 = var.oci_db_connection_string == "" || var.wls_version == "12.2.1.4" ? null : local.validators_msg_map[local.invalid_oci_db_connect_msg_use_4]
}
