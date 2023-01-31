# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {

  is_idcs_selected            = var.is_idcs_selected
  has_idcs_and_no_lb_selected = local.is_idcs_selected && !var.add_load_balancer
  invalid_idcs_cloudgate_port = (local.is_idcs_selected && var.idcs_cloudgate_port < 1024)
  missing_idcs_host           = (local.is_idcs_selected && var.idcs_host == "")
  missing_idcs_tenant         = (local.is_idcs_selected && var.idcs_tenant == "")
  missing_idcs_client_id      = (local.is_idcs_selected && var.idcs_client_id == "")
  missing_idcs_client_secret  = (local.is_idcs_selected && var.idcs_client_secret_id == "")

  # Validations
  idcs_and_no_lb_selected_msg            = "WLSC-ERROR: A load balancer is required when selecting IDCS"
  has_idcs_and_no_lb_selected_validation = local.has_idcs_and_no_lb_selected ? local.validators_msg_map[local.idcs_and_no_lb_selected_msg] : null

  idcs_cloudgate_port_msg      = "WLSC-ERROR: The value for idcs_cloudgate_port=[${var.idcs_cloudgate_port}] is not valid. The value has to be greater than 1023."
  validate_idcs_cloudgate_port = local.invalid_idcs_cloudgate_port ? local.validators_msg_map[local.idcs_cloudgate_port_msg] : null

  missing_idcs_host_msg      = "WLSC-ERROR: The value for idcs_host is required if using IDCS integration."
  validate_missing_idcs_host = local.missing_idcs_host ? local.validators_msg_map[local.missing_idcs_host_msg] : null

  missing_idcs_tenant_msg      = "WLSC-ERROR: The value for idcs_tenant is required if using IDCS integration."
  validate_missing_idcs_tenant = local.missing_idcs_tenant ? local.validators_msg_map[local.missing_idcs_tenant_msg] : null

  missing_idcs_client_id_msg      = "WLSC-ERROR: The value for idcs_client_id is required if using IDCS integration."
  validate_missing_idcs_client_id = local.missing_idcs_client_id ? local.validators_msg_map[local.missing_idcs_client_id_msg] : null

  missing_idcs_client_secret_msg      = "WLSC-ERROR: The value for idcs_client_secret is required if using IDCS integration."
  validate_missing_idcs_client_secret = local.missing_idcs_client_secret ? local.validators_msg_map[local.missing_idcs_client_secret_msg] : null

  #idcs secret OCID validations, idcs_client_secret_ocid is mapped to idcs_client_secret
  invalid_idcs_client_secret_msg = "WLSC-ERROR: The value for IDCS Client Secret [idcs_client_secret_ocid] is not valid. The value must begin with ocid1 followed by resource type, e.g. ocid1.vaultsecret."
  validate_idcs_client_secret    = var.is_idcs_selected && var.idcs_client_secret_id != "" ? length(regexall("^ocid1.vaultsecret.", var.idcs_client_secret_id)) > 0 ? null : local.validators_msg_map[local.invalid_idcs_client_secret_msg] : null
}
