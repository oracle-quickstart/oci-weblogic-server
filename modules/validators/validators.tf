# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {

  validators_msg_map = { #Dummy map to trigger an error in case we detect a validation error.
  }

  service_name_prefix         = replace(var.original_service_name, "/[^a-zA-Z0-9]/", "")
  invalid_service_name_prefix = (length(local.service_name_prefix) > 16) || (length(local.service_name_prefix) < 1) || (length(replace(substr(local.service_name_prefix, 0, 1), "/[0-9]/", "")) == 0) || length(local.service_name_prefix) != length(var.original_service_name)

  wls_port_list                     = tolist(["9071", "9072", "9073", "9074"])
  reserved_wls_ports                = contains(local.wls_port_list, var.wls_ms_port) || contains(local.wls_port_list, var.wls_ms_ssl_port) || contains(local.wls_port_list, var.wls_extern_admin_port) || contains(local.wls_port_list, var.wls_extern_ssl_admin_port)

  invalid_wls_admin_port_source_cidr = var.wls_expose_admin_port ? length(regexall("^(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9]).(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9]).(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9]).(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\\/(3[0-2]|[1-2]?[0-9])$", var.wls_admin_port_source_cidr)) == 0 : false

  # TODO Add the Validations as new modules are added

  service_name_prefix_msg      = "WLSC-ERROR: The [service_name] min length is 1 and max length is 16 characters. It can only contain letters or numbers and must begin with a letter. Invalid service name: [${var.original_service_name}]"
  validate_service_name_prefix = local.invalid_service_name_prefix ? local.validators_msg_map[local.service_name_prefix_msg] : null

  invalid_wls_admin_port_source_cidr_msg = "WLSC-ERROR: The value for wls_admin_port_source_cidr=[${var.wls_admin_port_source_cidr}] is not valid. The value does not match the regular expression ^(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9]).(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9]).(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9]).(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\\/(3[0-2]|[1-2]?[0-9])"
  validate_wls_admin_port_source_cidr    = local.invalid_wls_admin_port_source_cidr ? local.validators_msg_map[local.invalid_wls_admin_port_source_cidr_msg] : null

  reserved_wls_ports_msg = "WLSC-ERROR: The port range [9071-9074] is reserved for internal use. Please choose a port that is not in this range."
  validate_wls_ports     = local.reserved_wls_ports ? local.validators_msg_map[local.reserved_wls_ports_msg] : null

}



