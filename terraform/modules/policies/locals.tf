# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {

  label_prefix     = replace(var.resource_name_prefix, "/[^a-zA-Z0-9]/", "")
  compartment_rule = format("instance.compartment.id='%s'", var.compartment_id)
  network_vcn_id   = var.wls_existing_vcn_id != "" ? var.wls_existing_vcn_id : var.vcn_id

  # This policy with "use instances" verb is needed because there is code in the WebLogic for OCI compute image that updates metadata of the compute instance, when more than one VM nodes are created
  core_policy_statement1 = "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to use instances in compartment id ${var.compartment_id}"
  core_policy_statement2 = "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to inspect volumes in compartment id ${var.compartment_id}"
  core_policy_statement3 = "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to inspect volume-attachments in compartment id ${var.compartment_id}"
  # This policy with "inspect virtual-network-family" verb is needed to read VCN information like CIDR, etc, for VCN validation
  network_policy_statement1 = var.network_compartment_id != "" ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to inspect virtual-network-family in compartment id ${var.network_compartment_id}" : ""
  secrets_policy_statement1 = "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to read secret-bundles in tenancy where target.secret.id = '${var.wls_admin_password_id}'"
  secrets_policy_statement2 = (var.is_idcs_selected && var.idcs_client_secret_id != "") ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to read secret-bundles in tenancy where target.secret.id = '${var.idcs_client_secret_id}'" : ""
  atp_policy_statement1     = (var.atp_db.is_atp && var.atp_db.password_id != "") ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to read secret-bundles in tenancy where target.secret.id = '${var.atp_db.password_id}'" : ""
  # This policy with "use autonomous-transaction-processing-family" verb is needed to download ATP db wallet
  atp_policy_statement2    = (var.atp_db.is_atp && var.atp_db.compartment_id != "") ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to use autonomous-transaction-processing-family in compartment id ${var.atp_db.compartment_id}" : ""
  oci_db_policy_statement1 = var.oci_db.password_id != "" ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to read secret-bundles in tenancy where target.secret.id = '${var.oci_db.password_id}'" : ""
  # This policy with "inspect virtual-network-family" verb is needed to read OCI DB VCN information like CIDR, etc, for VCN validation
  oci_db_policy_statement2 = (var.oci_db.network_compartment_id != "" && var.oci_db.existing_vcn_id != local.network_vcn_id) ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to inspect virtual-network-family in compartment id ${var.oci_db.network_compartment_id} where target.vcn.id = '${var.oci_db.existing_vcn_id}'" : ""
  # This policy with "manage virtual-network-family" verb is needed to update security lists in the DB VCN when the DB VCN is different from the stack VCN
  oci_db_policy_statement3 = (var.oci_db.existing_vcn_add_seclist && var.oci_db.network_compartment_id != "" && var.oci_db.existing_vcn_id != local.network_vcn_id) ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to manage virtual-network-family in compartment id ${var.oci_db.network_compartment_id} where target.vcn.id = '${var.oci_db.existing_vcn_id}'" : ""
  # This policy with "use logging-family" verb is needed to create LogGroup & UnifiedAgentConfiguration and to push log content
  logging_policy = var.use_oci_logging ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to use logging-family in compartment id ${var.compartment_id}" : ""
  # This policy with "use apm-domains" verb is needed to list the data keys of the APM domain
  apm_domain_policy_statement = var.use_apm_service ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to use apm-domains in compartment id ${var.apm_domain_compartment_id}" : ""
  # This policy with "use load_balancer" verb is needed to create load balancer for new vcn
  lb_policy_statement = var.add_load_balancer ? length(oci_identity_dynamic_group.wlsc_instance_principal_group) > 0 ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to use load-balancers in compartment id ${var.network_compartment_id}" : "" : ""

  service_statements = compact([local.core_policy_statement1, local.core_policy_statement2, local.core_policy_statement3, local.network_policy_statement1, local.secrets_policy_statement1, local.secrets_policy_statement2, local.atp_policy_statement1, local.atp_policy_statement2, local.oci_db_policy_statement1, local.oci_db_policy_statement2, local.logging_policy, local.apm_domain_policy_statement, local.lb_policy_statement])

  cloning_policy_statement1 = "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to read orm-stacks in compartment id ${var.compartment_id}"
  cloning_policy_statement2 = "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to inspect compartments in tenancy"
  cloning_policy_statement  = compact([local.cloning_policy_statement1, local.cloning_policy_statement2])

  #TODO: When other categories with more statements are added here, concat them with service_statements
  policy_statements = concat(local.service_statements, local.cloning_policy_statement, [])

  reserved_ips_info = var.compartment_id == "" ? [{ id = var.resource_name_prefix }] : []

}
