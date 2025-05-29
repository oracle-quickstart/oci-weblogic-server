# Copyright (c) 2023, 2024, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {

  validators_msg_map = { #Dummy map to trigger an error in case we detect a validation error.
  }

  service_name_prefix         = replace(var.service_name, "/[^a-zA-Z0-9]/", "")
  invalid_service_name_prefix = (length(local.service_name_prefix) > 16) || (length(local.service_name_prefix) < 1) || (length(replace(substr(local.service_name_prefix, 0, 1), "/[0-9]/", "")) == 0) || length(local.service_name_prefix) != length(var.service_name)

  wls_port_list      = tolist(["9071", "9072", "9073", "9074"])
  reserved_wls_ports = contains(local.wls_port_list, var.wls_ms_port) || contains(local.wls_port_list, var.wls_ms_ssl_port) || contains(local.wls_port_list, var.wls_extern_admin_port) || contains(local.wls_port_list, var.wls_extern_ssl_admin_port)

  is14110Version               = var.wls_version == "14.1.1.0"
  invalid_14110_jrf            = local.is14110Version && (var.is_atp_db || var.is_oci_db || var.oci_db_connection_string != "")
  invalid_multiple_infra_dbs = ((var.is_oci_db || var.oci_db_connection_string != "") && var.is_atp_db)
  both_vcn_param             = local.has_existing_vcn && local.has_vcn_name

  invalid_dynamic_group = (!var.create_policies && var.use_oci_logging) ? length(regexall("^ocid1.dynamicgroup.", var.dynamic_group_id)) == 0 : false

  service_name_prefix_msg      = "WLSC-ERROR: The [service_name] min length is 1 and max length is 16 characters. It can only contain letters or numbers and must begin with a letter. Invalid service name: [${var.service_name}]"
  validate_service_name_prefix = local.invalid_service_name_prefix ? local.validators_msg_map[local.service_name_prefix_msg] : null

  reserved_wls_ports_msg = "WLSC-ERROR: The port range [9071-9074] is reserved for internal use. Please choose a port that is not in this range."
  validate_wls_ports     = local.reserved_wls_ports ? local.validators_msg_map[local.reserved_wls_ports_msg] : null

  multiple_infra_dbs_msg              = "WLSC-ERROR: Both OCI and ATP database parameters are provided. Only one infra database is required."
  validate_invalid_multiple_infra_dbs = local.invalid_multiple_infra_dbs ? local.validators_msg_map[local.multiple_infra_dbs_msg] : null

   jrf_14110_msg      = "WLSC-ERROR: JRF domain is not supported for FMW 14.1.1.0 version"
   validate_14c_jrf   = local.invalid_14110_jrf ? local.validators_msg_map[local.jrf_14110_msg] : ""

  missing_dynamic_group_oci_logging_enabled_create_policies_unset  = "WLSC-ERROR: Dynamic Group id is required when enabling integration with OCI Logging Service with create policies unset "
  validate_dynamic_group_oci_logging_enabled_create_policies_unset = !var.create_policies && var.use_oci_logging && var.dynamic_group_id == "" ? local.validators_msg_map[local.missing_dynamic_group_oci_logging_enabled_create_policies_unset] : null

  invalid_dynamic_group_msg   = "WLSC-ERROR: The value for Dynamic Group [dynamic_group_id] is not valid. The value must begin with ocid1 followed by resource type, e.g. ocid1.dynamicgroup."
  validate_dynamic_group_ocid = local.invalid_dynamic_group ? local.validators_msg_map[local.invalid_dynamic_group_msg] : null

  invalid_vm_count          = (var.num_vm_instances < 1) || (var.num_vm_instances > var.wls_node_count_limit)
  num_vm_instances_msg      = "WLSC-ERROR: The value for wls_node_count=[${var.num_vm_instances}] is not valid. The permissible value cannot exceed the value wls_node_count_limit=[${var.wls_node_count_limit}]."
  validate_num_vm_instances = local.invalid_vm_count ? local.validators_msg_map[local.num_vm_instances_msg] : null

  invalid_vmscripts_zip_bundle  = var.mode == "DEV" && var.wlsoci_vmscripts_zip_bundle_path == ""
  vmscripts_zip_bundle_msg      = "WLSC-ERROR: The value for wlsoci vmscripts zip bundle path is not valid. The value must be obsolute path to vmscripts zip bundle."
  validate_vmscripts_zip_bundle = local.invalid_vmscripts_zip_bundle ? local.validators_msg_map[local.vmscripts_zip_bundle_msg] : null

  new_ad_subnets                   = !var.use_regional_subnet && !var.use_existing_subnets
  new_ad_subnets_not_supported_msg = "WLSC-ERROR: Creating new AD specific subnets is not supported."
  new_ad_subnets_not_supported     = local.new_ad_subnets ? local.validators_msg_map[local.new_ad_subnets_not_supported_msg] : null

  missing_lb_availability_domains      = !var.use_regional_subnet && var.use_existing_subnets && local.add_new_load_balancer && (var.is_lb_private ? var.lb_availability_domain_name1 == "" : (var.lb_availability_domain_name1 == "" || var.lb_availability_domain_name2 == ""))
  lb_availability_domains_required_msg = "WLSC-ERROR: The values for lb_subnet_1_availability_domain_name and lb_subnet_2_availability_domain_name are required for AD specific subnets."
  missing_lb_availability_domain_names = local.missing_lb_availability_domains ? local.validators_msg_map[local.lb_availability_domains_required_msg] : null

  invalid_lb_availability_domain_indexes  = !var.use_regional_subnet && var.use_existing_subnets && local.add_new_load_balancer && var.lb_availability_domain_name1 != "" && (var.lb_availability_domain_name1 == var.lb_availability_domain_name2)
  lb_availability_domain_indexes_msg      = "WLSC-ERROR: The value for lb_subnet_1_availability_domain_name=[${var.lb_availability_domain_name1}] and lb_subnet_2_availability_domain_name=[${var.lb_availability_domain_name2}] cannot be same."
  validate_lb_availability_domain_indexes = local.invalid_lb_availability_domain_indexes ? local.validators_msg_map[local.lb_availability_domain_indexes_msg] : null

  invalid_script_version  = var.mode == "PROD" && var.tf_script_version == ""
  script_version_msg      = "WLSC-ERROR: The value for tf script version cannot be empty. Please provide valid script version that matches with version on the image."
  validate_script_version = local.invalid_script_version ? local.validators_msg_map[local.script_version_msg] : null

  # Validations related to Secured Production Mode
  missing_keystore_password_id          = var.configure_secure_mode && var.keystore_password_id == ""
  keystore_password_id_required_msg     = "WLSC-ERROR: The value for keystore_password_id is required when enabling secured production mode."
  validate_missing_keystore_password_id = local.missing_keystore_password_id ? local.validators_msg_map[local.keystore_password_id_required_msg] : null

  missing_root_ca_id          = var.configure_secure_mode && var.root_ca_id == ""
  root_ca_id_required_msg     = "WLSC-ERROR: The value for root_ca_id is required when enabling secured production mode."
  validate_missing_root_ca_id = local.missing_root_ca_id ? local.validators_msg_map[local.root_ca_id_required_msg] : null

  missing_wls_secondary_admin_password_id              = var.configure_secure_mode && var.wls_secondary_admin_password_id == ""
  missing_wls_secondary_admin_password_id_required_msg = "WLSC-ERROR: The value for wls_secondary_admin_password_id is required when enabling secured production mode"
  invalid_wls_secondary_admin_password_id              = var.configure_secure_mode && length(regexall("^ocid1.vaultsecret.", var.wls_secondary_admin_password_id)) <= 0
  invalid_wls_secondary_admin_password_id_required_msg = "WLSC-ERROR: The value for wls_secondary_admin_password_id should start with \"ocid1.vaultsecret.\""
  validate_wls_secondary_admin_password_id             = local.missing_wls_secondary_admin_password_id ? local.validators_msg_map[local.missing_wls_secondary_admin_password_id_required_msg] : (local.invalid_wls_secondary_admin_password_id ? local.validators_msg_map[local.invalid_wls_secondary_admin_password_id_required_msg] : null)

  invalid_administration_ports     = var.configure_secure_mode && var.administration_port == var.ms_administration_port
  invalid_administration_ports_msg = "WLSC-ERROR: The value for administration_port=[${var.administration_port}] and ms_administration_port=[${var.ms_administration_port}] cannot be same."
  validate_administration_ports    = local.invalid_administration_ports ? local.validators_msg_map[local.invalid_administration_ports_msg] : null

  is12cVersion                     = var.wls_version == "12.2.1.4"
  invalid_jrf_12c_secure_mode      = var.configure_secure_mode && local.is12cVersion && (var.is_oci_db || var.is_atp_db || trimspace(var.oci_db_connection_string) != "")
  invalid_jrf_12c_secure_mode_msg  = "WLSC-ERROR: JRF domain is not supported for FMW 12c version in secured production mode."
  validate_jrf_12c_secure_mode     = local.invalid_jrf_12c_secure_mode ? local.validators_msg_map[local.invalid_jrf_12c_secure_mode_msg] : ""

  missing_profile_id_msg = "WLSC-ERROR: The value for profile id is required if existing profile is used for OSMH"
  validate_profile_id    = (var.select_existing_profile && var.profile_ocid == "" ? local.validators_msg_map[local.missing_profile_id_msg] : null)
}
