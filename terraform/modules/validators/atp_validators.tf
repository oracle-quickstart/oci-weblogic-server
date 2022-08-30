# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {

  has_atp_db_password       = var.is_atp_db ? var.db_password_id != "" : true
  has_atp_db_compartment_id = var.is_atp_db ? var.atp_db_compartment_id != "" : true

  # Validate Missing ATP DB Password
  missing_atp_db_password_msg      = "WLSC-ERROR: The value for db_password_id is required."
  validate_missing_atp_db_password = local.has_atp_db_password == false ? local.validators_msg_map[local.missing_atp_db_password_msg] : null

  missing_atp_db_compartment_id          = "WLSC-ERROR: The value for atp_db_compartment_id is required."
  validate_missing_atp_db_compartment_id = local.has_atp_db_compartment_id ? null : local.validators_msg_map[local.missing_atp_db_compartment_id]

  invalid_atp_db_password_msg = "WLSC-ERROR: The value for ATP DB Admin Password [db_password_id] is not valid. The value must begin with ocid1 followed by resource type, e.g. ocid1.vaultsecret."
  validate_atp_db_password    = var.is_atp_db && var.db_password_id != "" ? length(regexall("^ocid1.vaultsecret.", var.db_password_id)) > 0 ? null : local.validators_msg_map[local.invalid_atp_db_password_msg] : null

}
