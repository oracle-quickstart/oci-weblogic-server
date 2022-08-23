# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {

  label_prefix     = replace(var.resource_name_prefix, "/[^a-zA-Z0-9]/", "")
  compartment_rule = format("instance.compartment.id='%s'", var.compartment_id)

  # This policy with "use instances" verb is needed because there is code in the WebLogic for OCI compute image that updates metadata of the compute instance, when more than one VM nodes are created
  core_policy_statement1    = "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to use instances in compartment id ${var.compartment_id}"
  core_policy_statement2    = "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to inspect volumes in compartment id ${var.compartment_id}"
  core_policy_statement3    = "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to inspect volume-attachments in compartment id ${var.compartment_id}"
  secrets_policy_statement1 = "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to read secret-bundles in tenancy where target.secret.id = '${var.wls_admin_password_id}'"
  secrets_policy_statement2 = (var.is_idcs_selected && var.idcs_client_secret_id != "") ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to read secret-bundles in tenancy where target.secret.id = '${var.idcs_client_secret_id}'" : ""
  atp_policy_statement1     = (var.atp_db.is_atp && var.atp_db.password_id != "") ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to read secret-bundles in tenancy where target.secret.id = '${var.atp_db.password_id}'" : ""
  # This policy with "use autonomous-transaction-processing-family" verb is needed to download ATP db wallet
  atp_policy_statement2     = (var.atp_db.is_atp && var.atp_db.compartment_id != "") ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to use autonomous-transaction-processing-family in compartment id ${var.atp_db.compartment_id}" : ""

  lb_policy_statement      = var.add_loadbalancer ? "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to use load-balancers in compartment id ${var.network_compartment_id}" : ""

  service_statements = compact([local.core_policy_statement1, local.core_policy_statement2, local.core_policy_statement3, local.secrets_policy_statement1, local.secrets_policy_statement2, local.atp_policy_statement1, local.atp_policy_statement2, local.lb_policy_statement])

  #TODO: When other categories with more statements are added here, concat them with service_statements
  policy_statements = concat(local.service_statements, [])

  reserved_ips_info = var.compartment_id == "" ? [{ id = var.resource_name_prefix } ] : []

}