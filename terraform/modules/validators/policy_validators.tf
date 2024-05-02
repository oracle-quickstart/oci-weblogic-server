# Copyright (c) 2024 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_identity_policies" "existing_policies" {
  compartment_id = var.tenancy_id
}

locals {
  policy_name = var.create_policies ? "${var.service_name}-oci-policy" : ""
  existing_policy_names = var.create_policies ? [for policy in data.oci_identity_policies.existing_policies.policies : policy.name] : []
  policy_already_exists = var.create_policies ? contains(local.existing_policy_names, local.policy_name) : false
  policy_already_exists_msg = "WLSC-ERROR: Policy with name ${local.policy_name} already exists. Suggested Actions: It appears that there is another resource with the same name already exists. This could be because you have previously provisioned another stack with the same name. If you no longer need the previous stack, please destroy and delete it so that all the resources are cleaned up or else you can provision again with a different stack prefix. If you have already deleted the stack, delete the policy ${local.policy_name}."
  validate_policy_name_is_not_already_used = var.create_policies && local.policy_already_exists ? local.validators_msg_map[local.policy_already_exists_msg] : null
}