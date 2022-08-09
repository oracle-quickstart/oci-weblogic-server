locals {

  label_prefix     = replace(var.resource_name_prefix, "/[^a-zA-Z0-9]/", "")
  compartment_rule = format("instance.compartment.id='%s'", var.compartment_id)

  # This policy with "use instances" verb is needed because there is code in the WebLogic for OCI compute image that updates metadata of the compute instance, when more than one VM nodes are created
  core_policy_statement1    = "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to use instances in compartment id ${var.compartment_id}"
  core_policy_statement2    = "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to inspect volumes in compartment id ${var.compartment_id}"
  core_policy_statement3    = "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to inspect volume-attachments in compartment id ${var.compartment_id}"
  secrets_policy_statement1 = "Allow dynamic-group ${oci_identity_dynamic_group.wlsc_instance_principal_group.name} to read secret-bundles in tenancy where target.secret.id = '${var.wls_admin_password_id}'"

  service_statements = compact([local.core_policy_statement1, local.core_policy_statement2, local.core_policy_statement3, local.secrets_policy_statement1])

  #TODO: When other categories with more statements are added here, concat them with service_statements
  policy_statements = concat(local.service_statements, [])

  reserved_ips_info = var.compartment_id == "" ? [{ id = var.resource_name_prefix } ] : []

}