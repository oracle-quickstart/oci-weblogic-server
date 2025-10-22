# Copyright (c) 2023, 2025, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {

  label_prefix     = replace(var.resource_name_prefix, "/[^a-zA-Z0-9]/", "")
  compartment_rule = format("instance.compartment.id='%s'", var.compartment_id)
  functions_rule   = format("ALL {resource.type = 'fnfunc', resource.compartment.id='%s', %s}", var.compartment_id, var.dynamic_group_rule)
  network_vcn_id   = var.wls_existing_vcn_id != "" ? var.wls_existing_vcn_id : var.vcn_id

  oci_db_connection_string = trimspace(var.oci_db.oci_db_connection_string)
  is_oci_db                = var.oci_db.is_oci_db || local.oci_db_connection_string != ""

  # This policy with "manage instances" verb is needed for 2 reasons:
  # 1. "use" is needed because there is code in the WebLogic for OCI compute image that updates metadata of the compute instance, when more than one VM node is created.
  # 2. "manage" is needed for cloning scenarios where volumes need to be added.
  core_policy_statement1 = "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to manage instances in compartment id ${var.compartment_id}"
  core_policy_statement2 = "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to manage volumes in compartment id ${var.compartment_id}"
  core_policy_statement3 = "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to manage volume-attachments in compartment id ${var.compartment_id}"
  core_policy_statement4 = "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to read instance-family in compartment id ${var.compartment_id}"
  # This policy with "inspect virtual-network-family" verb is needed to read VCN information like CIDR, etc, for VCN validation
  network_policy_statement1 = var.network_compartment_id != "" ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to inspect virtual-network-family in compartment id ${var.network_compartment_id}" : ""
  secrets_policy_statement1 = "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to read secret-bundles in tenancy where target.secret.id = '${var.wls_admin_password_id}'"
  secrets_policy_statement2 = (var.is_idcs_selected && var.idcs_client_secret_id != "") ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to read secret-bundles in tenancy where target.secret.id = '${var.idcs_client_secret_id}'" : ""
  atp_policy_statement1     = (var.atp_db.is_atp && var.atp_db.password_id != "") ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to read secret-bundles in tenancy where target.secret.id = '${var.atp_db.password_id}'" : ""
  # This policy with "use autonomous-transaction-processing-family" verb is needed to download ATP db wallet
  atp_policy_statement2 = (var.atp_db.is_atp && var.atp_db.compartment_id != "") ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to use autonomous-transaction-processing-family in compartment id ${var.atp_db.compartment_id}" : ""
  # This policy with "manage network-security-groups" verb is needed to add security rule in the ATP db (with private endpoint) NSG in the ATP db VCN
  atp_policy_statement3    = (var.atp_db.is_atp_with_private_endpoints && var.atp_db.existing_vcn_add_seclist && var.atp_db.network_compartment_id != "") ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to manage network-security-groups in compartment id ${var.atp_db.network_compartment_id} where request.operation = 'AddNetworkSecurityGroupSecurityRules'" : ""
  oci_db_policy_statement1 = var.oci_db.password_id != "" ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to read secret-bundles in tenancy where target.secret.id = '${var.oci_db.password_id}'" : ""
  # This policy with "inspect virtual-network-family" verb is needed to read OCI DB VCN information like CIDR, etc, for VCN validation
  oci_db_policy_statement2 = (var.oci_db.network_compartment_id != "" && var.oci_db.existing_vcn_id != local.network_vcn_id) ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to inspect virtual-network-family in compartment id ${var.oci_db.network_compartment_id} where target.vcn.id = '${var.oci_db.existing_vcn_id}'" : ""
  # This policy with "manage virtual-network-family" verb is needed to update security lists in the DB VCN when the DB VCN is different from the stack VCN
  oci_db_policy_statement3 = (var.oci_db.existing_vcn_add_seclist && var.oci_db.network_compartment_id != "" && var.oci_db.existing_vcn_id != local.network_vcn_id) ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to manage virtual-network-family in compartment id ${var.oci_db.network_compartment_id} where target.vcn.id = '${var.oci_db.existing_vcn_id}'" : ""
  # This policy with "use logging-family" verb is needed to create LogGroup & UnifiedAgentConfiguration and to push log content
  logging_policy = var.use_oci_logging ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to use logging-family in compartment id ${var.compartment_id}" : ""
  # This policy with "use apm-domains" verb is needed to list the data keys of the APM domain
  apm_domain_policy_statement = var.use_apm_service ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to use apm-domains in compartment id ${var.apm_domain_compartment_id}" : ""
  # This policy with "use load_balancer" verb is needed because there is code in the Weblogic for OCI compute image that sets the lb backend states.
  lb_policy_statement = var.add_load_balancer ? length(oci_identity_dynamic_group.wlsc_instance_principal_group) > 0 ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to use load-balancers in compartment id ${var.network_compartment_id}" : "" : ""
  service_statements = compact([local.core_policy_statement1, local.core_policy_statement2, local.core_policy_statement3, local.core_policy_statement4, local.network_policy_statement1, local.secrets_policy_statement1, local.secrets_policy_statement2,
    local.atp_policy_statement1, local.atp_policy_statement2, local.atp_policy_statement3, local.oci_db_policy_statement1, local.oci_db_policy_statement2, local.oci_db_policy_statement3, local.logging_policy,
    local.apm_domain_policy_statement, local.lb_policy_statement
  ])

  cloning_policy_statement1 = "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to read orm-stacks in compartment id ${var.compartment_id}"
  cloning_policy_statement2 = "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to inspect compartments in tenancy"
  cloning_policy_statement  = compact([local.cloning_policy_statement1, local.cloning_policy_statement2])

  # These policy statements are required for disabling the OSMS plugin
  plugin_policy_statement1 = "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to manage instance-agent-plugins in compartment id ${var.compartment_id}"
  plugin_policy_statement = compact([local.plugin_policy_statement1])

  # Policies required for enabling the OSMH plugin
  osmh_policy_statement1 = var.enable_osmh? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to manage osmh-family in compartment id ${var.compartment_id}" : ""
  osmh_policy_statement2 = var.enable_osmh? var.profile_compartment_id != var.compartment_id? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to manage osmh-family in compartment id  ${var.profile_compartment_id}" : "" : ""
  osmh_policy_statement3 = var.enable_osmh? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to {OSMH_MANAGED_INSTANCE_ACCESS} in tenancy where request.principal.id = target.managed-instance.id" : ""
  osmh_policy_statement4 = var.enable_osmh? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to {MGMT_AGENT_DEPLOY_PLUGIN_CREATE, MGMT_AGENT_INSPECT, MGMT_AGENT_READ} in compartment id ${var.compartment_id}" : ""
  osmh_policy_statement  = compact([local.osmh_policy_statement1, local.osmh_policy_statement2, local.osmh_policy_statement3, local.osmh_policy_statement4])


  #Policies for WLS instance principal dynamic group
  autoscaling_statement1 = var.use_autoscaling ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to use repos in tenancy" : ""
  autoscaling_statement2 = var.use_autoscaling ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to manage functions-family in compartment id ${var.compartment_id}" : ""
  autoscaling_statement3 = var.use_autoscaling ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to manage ons-subscriptions in compartment id ${var.compartment_id}" : ""

  #Policies for OCI Functions principal dynamic group
  autoscaling_statement4  = var.use_autoscaling ? length(oci_identity_dynamic_group.wlsc_functions_principal_group) > 0 ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_functions_principal_group[0].name} to inspect tenancies in tenancy" : "" : ""
  autoscaling_statement5  = var.use_autoscaling ? length(oci_identity_dynamic_group.wlsc_functions_principal_group) > 0 ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_functions_principal_group[0].name} to inspect limits in tenancy" : "" : ""
  autoscaling_statement6  = var.use_autoscaling ? length(oci_identity_dynamic_group.wlsc_functions_principal_group) > 0 ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_functions_principal_group[0].name} to manage volume-family in compartment id ${var.compartment_id}" : "" : ""
  autoscaling_statement7  = var.use_autoscaling ? length(oci_identity_dynamic_group.wlsc_functions_principal_group) > 0 ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_functions_principal_group[0].name} to manage instance-family in compartment id ${var.compartment_id}" : "" : ""
  autoscaling_statement8  = var.use_autoscaling ? length(oci_identity_dynamic_group.wlsc_functions_principal_group) > 0 ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_functions_principal_group[0].name} to use app-catalog-listing in compartment id ${var.compartment_id}" : "" : ""
  autoscaling_statement9  = var.use_autoscaling ? length(oci_identity_dynamic_group.wlsc_functions_principal_group) > 0 ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_functions_principal_group[0].name} to manage virtual-network-family in compartment id ${var.network_compartment_id}" : "" : ""
  autoscaling_statement10 = var.use_autoscaling ? length(oci_identity_dynamic_group.wlsc_functions_principal_group) > 0 ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_functions_principal_group[0].name} to manage load-balancers in compartment id ${var.network_compartment_id}" : "" : ""
  autoscaling_statement11 = var.use_autoscaling ? length(oci_identity_dynamic_group.wlsc_functions_principal_group) > 0 ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_functions_principal_group[0].name} to manage orm-family in compartment id ${var.compartment_id}" : "" : ""
  autoscaling_statement12 = var.use_autoscaling ? length(oci_identity_dynamic_group.wlsc_functions_principal_group) > 0 ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_functions_principal_group[0].name} to read metrics in compartment id ${var.compartment_id}" : "" : ""
  autoscaling_statement13 = var.use_autoscaling ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to use instance-agent-command-execution-family in compartment id ${var.compartment_id}" : ""
  autoscaling_statement14 = var.use_autoscaling ? length(oci_identity_dynamic_group.wlsc_functions_principal_group) > 0 ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_functions_principal_group[0].name} to manage repos in tenancy" : "" : ""
  autoscaling_statement15 = var.use_autoscaling ? length(oci_identity_dynamic_group.wlsc_functions_principal_group) > 0 ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_functions_principal_group[0].name} to manage functions-family in compartment id ${var.compartment_id}" : "" : ""
  autoscaling_statement16 = var.use_autoscaling ? length(oci_identity_dynamic_group.wlsc_functions_principal_group) > 0 ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_functions_principal_group[0].name} to manage ons-topics in compartment id ${var.compartment_id}" : "" : ""
  autoscaling_statement17 = var.use_autoscaling ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to use tag-namespaces in tenancy" : ""
  autoscaling_statement18 = var.use_autoscaling ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to read secret-bundles in tenancy where target.secret.id = '${var.ocir_auth_token_id}'" : ""
  autoscaling_statement19 = var.use_autoscaling ? length(oci_identity_dynamic_group.wlsc_functions_principal_group) > 0 ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_functions_principal_group[0].name} to manage instance-agent-command-family in compartment id ${var.compartment_id}" : "" : ""
  autoscaling_statement20 = var.use_autoscaling ? length(oci_identity_dynamic_group.wlsc_functions_principal_group) > 0 ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_functions_principal_group[0].name} to use apm-domains in compartment id ${var.apm_domain_compartment_id}" : "" : ""
  autoscaling_statement21 = var.use_autoscaling ? length(oci_identity_dynamic_group.wlsc_functions_principal_group) > 0 ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_functions_principal_group[0].name} to manage alarms in compartment id ${var.compartment_id}" : "" : ""
  autoscaling_statement22 = var.use_autoscaling ? length(oci_identity_dynamic_group.wlsc_functions_principal_group) > 0 ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_functions_principal_group[0].name} to use unified-configuration in compartment id ${var.compartment_id}" : "" : ""
  autoscaling_statement23 = var.use_autoscaling ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to manage cloudevents-rules in compartment id ${var.compartment_id}" : ""
  autoscaling_statement24 = var.use_autoscaling ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to use ons-topics in compartment id ${var.compartment_id}" : ""

  autoscaling_statement25                       = var.use_autoscaling ? length(oci_identity_dynamic_group.wlsc_functions_principal_group) > 0 ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_functions_principal_group[0].name} to inspect dynamic-groups in tenancy" : "" : ""
  autoscaling_statement26                       = var.use_autoscaling ? length(oci_identity_dynamic_group.wlsc_functions_principal_group) > 0 ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_functions_principal_group[0].name} to manage policies in tenancy" : "" : ""
  autoscaling_statement27                       = var.use_autoscaling ? length(oci_identity_dynamic_group.wlsc_functions_principal_group) > 0 ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_functions_principal_group[0].name} to use tag-namespaces in tenancy" : "" : ""
  autoscaling_statement28                       = var.use_autoscaling && var.network_compartment_id != var.compartment_id && var.is_rms_private_endpoint_required ? length(oci_identity_dynamic_group.wlsc_functions_principal_group) > 0 ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_functions_principal_group[0].name} to manage orm-family in compartment id ${var.network_compartment_id}" : "" : ""
  autoscaling_statement29                       = (var.use_autoscaling && var.instance_image_id != "") ? length(oci_identity_dynamic_group.wlsc_functions_principal_group) > 0 ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_functions_principal_group[0].name} to {INSTANCE_IMAGE_READ} in tenancy where target.image.id='${var.instance_image_id}'" : "" : ""
  autoscaling_atp_policy_statement              = (var.atp_db.is_atp && var.use_autoscaling) ? length(oci_identity_dynamic_group.wlsc_functions_principal_group) > 0 ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_functions_principal_group[0].name} to inspect autonomous-transaction-processing-family in compartment id ${var.atp_db.compartment_id}" : "" : ""
  autoscaling_db_policy_statement               = (local.is_oci_db && var.use_autoscaling) ? length(oci_identity_dynamic_group.wlsc_functions_principal_group) > 0 ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_functions_principal_group[0].name} to inspect database-family in compartment id ${var.oci_db.compartment_id}" : "" : ""
  autoscaling_fss_mount_target_policy_statement = (var.add_fss && var.use_autoscaling) ? length(oci_identity_dynamic_group.wlsc_functions_principal_group) > 0 ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_functions_principal_group[0].name} to manage mount-targets in compartment id ${var.mount_target_compartment_id}" : "" : ""
  autoscaling_fss_file_system_policy_statement  = (var.add_fss && var.use_autoscaling) ? length(oci_identity_dynamic_group.wlsc_functions_principal_group) > 0 ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_functions_principal_group[0].name} to manage file-systems in compartment id ${var.fss_compartment_id}" : "" : ""
  autoscaling_fss_export_sets_policy_statement  = (var.add_fss && var.use_autoscaling) ? length(oci_identity_dynamic_group.wlsc_functions_principal_group) > 0 ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_functions_principal_group[0].name} to manage export-sets in compartment id ${var.fss_compartment_id}" : "" : ""

  #logging policies
  autoscaling_logging_policy_1 = (var.use_oci_logging && var.use_autoscaling) ? length(oci_identity_dynamic_group.wlsc_functions_principal_group) > 0 ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_functions_principal_group[0].name} to manage log-groups in compartment id ${var.compartment_id}" : "" : ""
  autoscaling_logging_policy_2 = (var.use_oci_logging && var.use_autoscaling) ? length(oci_identity_dynamic_group.wlsc_functions_principal_group) > 0 ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_functions_principal_group[0].name} to use log-content in compartment id ${var.compartment_id}" : "" : ""
  autoscaling_logging_policy_3 = (var.use_oci_logging && var.use_autoscaling) ? length(oci_identity_dynamic_group.wlsc_functions_principal_group) > 0 ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_functions_principal_group[0].name} to manage unified-configuration in compartment id ${var.compartment_id}" : "" : ""

  autoscaling_statements = compact([local.autoscaling_statement1, local.autoscaling_statement2,
    local.autoscaling_statement3, local.autoscaling_statement4, local.autoscaling_statement5,
    local.autoscaling_statement6, local.autoscaling_statement7, local.autoscaling_statement8,
    local.autoscaling_statement9, local.autoscaling_statement10, local.autoscaling_statement11,
    local.autoscaling_statement12, local.autoscaling_statement13, local.autoscaling_statement14,
    local.autoscaling_statement15, local.autoscaling_statement16, local.autoscaling_statement17,
    local.autoscaling_statement18, local.autoscaling_statement19, local.autoscaling_statement20,
    local.autoscaling_statement21, local.autoscaling_statement22, local.autoscaling_statement23,
    local.autoscaling_statement24, local.autoscaling_statement25, local.autoscaling_statement26,
    local.autoscaling_statement27, local.autoscaling_statement28, local.autoscaling_statement29,
    local.autoscaling_logging_policy_1, local.autoscaling_logging_policy_2, local.autoscaling_logging_policy_3,
    local.autoscaling_atp_policy_statement,
    local.autoscaling_db_policy_statement,
    local.autoscaling_fss_mount_target_policy_statement,
    local.autoscaling_fss_file_system_policy_statement,
    local.autoscaling_fss_export_sets_policy_statement
  ])

  #Policies for creating wildcard certificate to configure SSL in secured production mode
  secure_mode_statement1 = var.configure_secure_mode ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to use certificate-authority-delegates in compartment id ${var.root_ca_compartment_id}" : ""
  secure_mode_statement2 = var.configure_secure_mode ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to manage leaf-certificates in compartment id ${var.cert_compartment_id}" : ""
  secure_mode_statement3 = var.configure_secure_mode ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to read leaf-certificate-bundles in compartment id ${var.cert_compartment_id} where target.leaf-certificate.bundle-type = 'CERTIFICATE_CONTENT_PUBLIC_ONLY'"  : ""
  secure_mode_statement4 = var.configure_secure_mode ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to read certificate-authorities in compartment id ${var.root_ca_compartment_id}" : ""
  secure_mode_statement5 = (var.configure_secure_mode && var.use_autoscaling) ? length(oci_identity_dynamic_group.wlsc_functions_principal_group) > 0 ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_functions_principal_group[0].name} to read certificate-authorities in compartment id ${var.root_ca_compartment_id}" : "" : ""

  #Policy for reading keystore password secret
  secure_mode_secrets_policy_statement1 = (var.configure_secure_mode && var.keystore_password_id != "" && var.wls_secondary_admin_password_id != "" && var.keystore_password_id != var.wls_admin_password_id && var.keystore_password_id != var.wls_secondary_admin_password_id) ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to read secret-bundles in tenancy where target.secret.id = '${var.keystore_password_id}'" : ""
  secure_mode_secrets_policy_statement2 = (var.configure_secure_mode && var.wls_secondary_admin_password_id != "" && var.wls_admin_password_id != var.wls_secondary_admin_password_id) ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to read secret-bundles in tenancy where target.secret.id = '${var.wls_secondary_admin_password_id}'" : ""
  secure_mode_statement  = compact([local.secure_mode_statement1, local.secure_mode_statement2, local.secure_mode_statement3, local.secure_mode_statement4, local.secure_mode_statement5, local.secure_mode_secrets_policy_statement1, local.secure_mode_secrets_policy_statement2])

  #TODO: When other categories with more statements are added here, concat them with service_statements
  policy_statements = concat(local.service_statements, local.cloning_policy_statement, local.plugin_policy_statement, local.secure_mode_statement, local.osmh_policy_statement)

  reserved_ips_info = var.compartment_id == "" ? [{ id = var.resource_name_prefix }] : []

}
