# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {

  # cidr values validation
  has_wls_subnet_cidr  = var.wls_subnet_cidr != ""
  has_mgmt_subnet_cidr = var.is_bastion_instance_required ? (var.bastion_subnet_cidr != "" || var.existing_bastion_instance_id != "") : true

  has_lb_subnet_1_cidr    = var.lb_subnet_1_cidr != ""
  missing_wls_subnet_cidr = var.existing_vcn_id != "" && var.wls_subnet_id == "" ? !local.has_wls_subnet_cidr : false
  add_new_load_balancer   = var.add_load_balancer && var.existing_load_balancer_id == ""
  missing_lb_subnet_1_cidr = local.add_new_load_balancer && var.existing_vcn_id != "" && var.lb_subnet_1_id == "" ? !local.has_lb_subnet_1_cidr : false

  invalid_wls_admin_port_source_cidr = var.wls_expose_admin_port ? length(regexall("^(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9]).(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9]).(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9]).(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\\/(3[0-2]|[1-2]?[0-9])$", var.wls_admin_port_source_cidr)) == 0 : false
  missing_mgmt_backend_subnet_cidr   = (var.existing_vcn_id != "" && !var.assign_public_ip && var.bastion_subnet_id == "" && var.is_bastion_instance_required && var.existing_bastion_instance_id == "") ? !local.has_mgmt_subnet_cidr : false

  duplicate_wls_subnet_cidr_with_lb1_cidr            = (local.add_new_load_balancer) && (local.has_lb_subnet_1_cidr) && (local.has_wls_subnet_cidr) && (var.wls_subnet_cidr == var.lb_subnet_1_cidr)
  duplicate_wls_subnet_cidr_with_private_subnet_cidr = ((var.existing_vcn_id == "") && (!var.assign_public_ip) && var.bastion_subnet_id == "") && (local.has_mgmt_subnet_cidr) && (local.has_wls_subnet_cidr) && (var.wls_subnet_cidr == var.bastion_subnet_cidr)

  check_duplicate_wls_subnet_cidr = var.wls_subnet_cidr != "" && (local.duplicate_wls_subnet_cidr_with_lb1_cidr || local.duplicate_wls_subnet_cidr_with_private_subnet_cidr)

  #lb1 check
  duplicate_lb1_subnet_cidr_with_private_subnet_cidr = ((!var.assign_public_ip) && var.bastion_subnet_id == "") && (local.has_mgmt_subnet_cidr) && (local.has_lb_subnet_1_cidr) && (var.lb_subnet_1_cidr == var.bastion_subnet_cidr)
  check_duplicate_lb1_subnet_cidr                    = local.has_lb_subnet_1_cidr && local.duplicate_lb1_subnet_cidr_with_private_subnet_cidr

  missing_vcn               = var.existing_vcn_id == "" && var.vcn_name == ""
  has_existing_vcn          = var.existing_vcn_id != ""
  has_vcn_name              = var.vcn_name != ""
  has_wls_subnet_id         = var.wls_subnet_id != ""
  has_lb_backend_subnet_id  = var.lb_subnet_2_id != ""
  has_lb_frontend_subnet_id = var.lb_subnet_1_id != ""
  missing_bastion_subnet_id = (var.is_bastion_instance_required && var.existing_bastion_instance_id != "" && var.bastion_subnet_id == "")
  has_mgmt_subnet_id        = var.is_bastion_instance_required ? var.bastion_subnet_id != "" : true

  missing_vcn_id                = (var.existing_vcn_id == "" && (local.has_wls_subnet_id || local.has_lb_backend_subnet_id || local.has_lb_frontend_subnet_id))
  missing_private_subnet_vcn_id = (var.is_bastion_instance_required && (var.bastion_subnet_id != "" || var.existing_bastion_instance_id != "") && var.existing_vcn_id == "")


  #existing subnets
  # If load balancer selected, check LB and WLS have existing subnet IDs specified else, if load balancer is not selected, check if WLS is using existing subnet id
  has_all_existing_subnets = (local.add_new_load_balancer && local.has_wls_subnet_id && local.has_lb_backend_subnet_id && local.has_lb_frontend_subnet_id) || (!local.add_new_load_balancer && local.has_wls_subnet_id)

  has_all_new_subnets      = (local.add_new_load_balancer && !local.has_wls_subnet_id && !local.has_lb_backend_subnet_id && !local.has_lb_frontend_subnet_id) || (!local.add_new_load_balancer && !local.has_wls_subnet_id)
  is_subnet_condition      = (local.has_all_existing_subnets || local.has_all_new_subnets)
  missing_existing_subnets = (var.assign_public_ip) ? local.is_subnet_condition : false

  #existing private AD subnet
  has_all_existing_private_subnets = (local.add_new_load_balancer && local.has_wls_subnet_id && local.has_lb_frontend_subnet_id && local.has_mgmt_subnet_id) || ((!local.add_new_load_balancer && local.has_wls_subnet_id && local.has_mgmt_subnet_id))
  has_all_new_private_subnets      = (local.add_new_load_balancer && local.has_wls_subnet_cidr && local.has_lb_subnet_1_cidr && local.has_mgmt_subnet_cidr) || (!local.add_new_load_balancer && local.has_wls_subnet_cidr && local.has_mgmt_subnet_cidr)
  is_private_subnet_condition      = (local.has_all_existing_private_subnets || local.has_all_new_private_subnets)
  missing_existing_private_subnets = !local.is_private_subnet_condition

  #existing regional validation
  has_all_existing_regional_subnets = (local.add_new_load_balancer && local.has_wls_subnet_id && local.has_lb_frontend_subnet_id) || (!local.add_new_load_balancer && local.has_wls_subnet_id)
  has_all_new_regional_subnets      = (local.add_new_load_balancer && local.has_wls_subnet_cidr && local.has_lb_subnet_1_cidr) || (!local.add_new_load_balancer && local.has_wls_subnet_cidr)
  is_regional_subnet_condition      = (local.has_all_existing_regional_subnets || local.has_all_new_regional_subnets)
  has_existing_regional_subnets     = local.is_regional_subnet_condition

  #existing private regional validation
  has_all_existing_private_regional_subnets = (local.add_new_load_balancer && local.has_wls_subnet_id && local.has_lb_frontend_subnet_id && local.has_mgmt_subnet_id) || (!local.add_new_load_balancer && local.has_wls_subnet_id && local.has_mgmt_subnet_id)
  has_all_new_private_regional_subnets      = (local.add_new_load_balancer && local.has_wls_subnet_cidr && local.has_lb_subnet_1_cidr && local.has_mgmt_subnet_cidr) || (!local.add_new_load_balancer && local.has_wls_subnet_cidr && local.has_mgmt_subnet_cidr)
  is_private_regional_subnet_condition      = (local.has_all_existing_private_regional_subnets || local.has_all_new_private_regional_subnets)
  has_existing_private_regional_subnets     = local.is_private_regional_subnet_condition

  #disable bastion host provisioning in private subnet
  is_bastion_turned_off         = !var.is_bastion_instance_required
  is_existing_bastion_condition = (!var.assign_public_ip && var.is_bastion_instance_required && var.existing_bastion_instance_id != "")
  bastion_ssh_key_file          = var.bastion_ssh_private_key == "" ? "missing.txt" : var.bastion_ssh_private_key
  invalid_bastion_private_key   = (local.is_existing_bastion_condition && (var.bastion_ssh_private_key == "" || !fileexists(local.bastion_ssh_key_file)))

  invalid_bastion_config     = (var.existing_vcn_id == "" || (local.has_existing_vcn && var.wls_subnet_id == "")) ? local.is_bastion_turned_off : false
  invalid_bastion_config_msg = "WLSC-ERROR: Provisioning in private subnet without bastion instance has to be limited for VCN with existing subnets."
  validate_bastion_config    = (local.invalid_bastion_config) ? local.validators_msg_map[local.invalid_bastion_config_msg] : null

  invalid_lb_type = var.is_lb_private && var.assign_public_ip

  # VCN peering
  missing_db_vcn_lpg = var.is_vcn_peering ? var.db_vcn_lpg_id == "" : false

  # Validations
  vcn_params_msg      = "WLSC-ERROR: At least wls_existing_vcn_id or wls_vcn_name must be provided."
  validate_vcn_params = local.missing_vcn ? local.validators_msg_map[local.vcn_params_msg] : null

  both_vcn_param_msg      = "WLSC-ERROR: Both wls_existing_vcn_id and wls_vcn_name cannot be provided."
  validate_both_vcn_param = local.both_vcn_param ? local.validators_msg_map[local.both_vcn_param_msg] : null

  missing_wls_subnet_cidr_msg      = "WLSC-ERROR: The value for wls_subnet_cidr is required if existing virtual cloud network is used."
  validate_missing_wls_subnet_cidr = local.missing_wls_subnet_cidr ? local.validators_msg_map[local.missing_wls_subnet_cidr_msg] : null

  missing_lb_subnet_1_cidr_msg      = "WLSC-ERROR: The value for lb_subnet_1_cidr is required if existing virtual cloud network is used and LB is added."
  validate_missing_lb_subnet_1_cidr = local.missing_lb_subnet_1_cidr ? local.validators_msg_map[local.missing_lb_subnet_1_cidr_msg] : null

  missing_bastion_subnet_id_msg      = "WLSC-ERROR: The value for bastion subnet id is required if existing bastion instance id is used for provisioning"
  validate_missing_bastion_subnet_id = local.missing_bastion_subnet_id ? local.validators_msg_map[local.missing_bastion_subnet_id_msg] : null

  missing_mgmt_backend_subnet_cidr_msg      = "WLSC-ERROR: The value for bastion_subnet_cidr is required with existing virtual cloud network and weblogic in private subnet."
  validate_missing_mgmt_backend_subnet_cidr = local.missing_mgmt_backend_subnet_cidr ? local.validators_msg_map[local.missing_mgmt_backend_subnet_cidr_msg] : null

  missing_vcn_id_msg      = "WLSC-ERROR: The value for existing_vcn_id is required if existing subnets are used for provisioning."
  validate_missing_vcn_id = local.missing_vcn_id ? local.validators_msg_map[local.missing_vcn_id_msg] : null

  missing_private_subnet_vcn_id_msg      = "WLSC-ERROR: The value for existing_vcn_id is required if existing bastion subnet id is used for provisioning."
  validate_missing_private_subnet_vcn_id = local.missing_private_subnet_vcn_id ? local.validators_msg_map[local.missing_private_subnet_vcn_id_msg] : null

  wls_subnet_cidr_msg       = "WLSC-ERROR:  WebLogic subnet CIDR has to be unique value."
  duplicate_wls_subnet_cidr = local.check_duplicate_wls_subnet_cidr == true ? local.validators_msg_map[local.wls_subnet_cidr_msg] : null

  duplicate_lb1_subnet_cidr_msg = "WLSC-ERROR:  Load balancer subnet 1 CIDR has to be unique value."
  duplicate_lb1_subnet_cidr     = local.check_duplicate_lb1_subnet_cidr ? local.validators_msg_map[local.duplicate_lb1_subnet_cidr_msg] : null

  lb_type_msg      = "WLSC-ERROR: Private load balancer can only be provisioned if private subnets are used for provisioning."
  validate_lb_type = local.invalid_lb_type ? local.validators_msg_map[local.lb_type_msg] : null

  missing_existing_subnets_msg      = "WLSC-ERROR: Provide all required existing subnet id if one of the existing subnets is provided [ lb_subnet_1_id, lb_subnet_2_id, wls_subnet_id ]."
  validate_missing_existing_subnets = var.use_regional_subnet ? false : local.missing_existing_subnets

  missing_existing_private_subnets_msg      = "WLSC-ERROR: Provide all required existing subnet ids or subnet CIDRs if one of the existing subnets is provided [ lb_subnet_1_id/cidr, lb_subnet_2_id/cidr, wls_subnet_id/cidr, bastion_subnet_id/cidr ]."
  validate_missing_existing_private_subnets = !var.assign_public_ip && !var.use_regional_subnet && local.missing_existing_private_subnets ? local.validators_msg_map[local.missing_existing_private_subnets_msg] : null

  missing_existing_regional_subnets_msg      = "WLSC-ERROR: Provide all required existing subnet id if one of the existing subnets is provided[ lb_subnet_1_id, wls_subnet_id ]."
  validate_missing_existing_regional_subnets = var.use_regional_subnet && !local.has_existing_regional_subnets ? local.validators_msg_map[local.missing_existing_regional_subnets_msg] : null

  missing_existing_private_regional_subnets_msg      = "WLSC-ERROR: Provide all required existing subnet ids or subnet CIDRs if one of the existing subnets is provided [ lb_subnet_1_id/cidr, wls_subnet_id/cidr, bastion_subnet_id/cidr ]."
  validate_missing_existing_private_regional_subnets = !var.assign_public_ip && var.use_regional_subnet && !local.has_existing_private_regional_subnets ? local.validators_msg_map[local.missing_existing_private_regional_subnets_msg] : null

  missing_existing_bastion_host_private_subnet_msg      = "WLSC-ERROR: Support existing bastion host for provisioning WLS in private subnet is enabled in CLI only. Provide all required parameters [ is_bastion_instance_required, existing_bastion_instance_id, bastion_ssh_private_key ]."
  validate_missing_existing_bastion_host_private_subnet = (local.invalid_bastion_private_key) ? local.validators_msg_map[local.missing_existing_bastion_host_private_subnet_msg] : null

  missing_db_vcn_lpg_msg      = "WLSC-ERROR: The value for db_vcn_lpg_id is required for VCN peering."
  validate_missing_db_vcn_lpg = local.missing_db_vcn_lpg ? local.validators_msg_map[local.missing_db_vcn_lpg_msg] : null

}

