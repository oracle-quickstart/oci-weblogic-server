# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {

  validators_msg_map = { #Dummy map to trigger an error in case we detect a validation error.
  }

  service_name_prefix         = replace(var.service_name, "/[^a-zA-Z0-9]/", "")
  invalid_service_name_prefix = (length(local.service_name_prefix) > 16) || (length(local.service_name_prefix) < 1) || (length(replace(substr(local.service_name_prefix, 0, 1), "/[0-9]/", "")) == 0) || length(local.service_name_prefix) != length(var.service_name)

  wls_port_list      = tolist(["9071", "9072", "9073", "9074"])
  reserved_wls_ports = contains(local.wls_port_list, var.wls_ms_port) || contains(local.wls_port_list, var.wls_ms_ssl_port) || contains(local.wls_port_list, var.wls_extern_admin_port) || contains(local.wls_port_list, var.wls_extern_ssl_admin_port)

  is14cVersion               = var.wls_version == "14.1.1.0"
  invalid_14c_jrf            = local.is14cVersion && (var.is_atp_db || var.is_oci_db || var.oci_db_connection_string != "")
  invalid_multiple_infra_dbs = ((var.is_oci_db || var.oci_db_connection_string != "") && var.is_atp_db)
  both_vcn_param_non_ocidb   = ! var.is_oci_db ? (local.has_existing_vcn && local.has_vcn_name) : false

  # TODO Add the Validations as new modules are added

  service_name_prefix_msg      = "WLSC-ERROR: The [service_name] min length is 1 and max length is 16 characters. It can only contain letters or numbers and must begin with a letter. Invalid service name: [${var.service_name}]"
  validate_service_name_prefix = local.invalid_service_name_prefix ? local.validators_msg_map[local.service_name_prefix_msg] : null

  reserved_wls_ports_msg = "WLSC-ERROR: The port range [9071-9074] is reserved for internal use. Please choose a port that is not in this range."
  validate_wls_ports     = local.reserved_wls_ports ? local.validators_msg_map[local.reserved_wls_ports_msg] : null

  multiple_infra_dbs_msg              = "WLSC-ERROR: Both OCI and ATP database parameters are provided. Only one infra database is required."
  validate_invalid_multiple_infra_dbs = local.invalid_multiple_infra_dbs ? local.validators_msg_map[local.multiple_infra_dbs_msg] : null

  jrf_14c_msg      = "WLSC-ERROR: JRF domain is not supported for FMW 14c version"
  validate_14c_jrf = local.invalid_14c_jrf ? local.validators_msg_map[local.jrf_14c_msg] : ""
}



