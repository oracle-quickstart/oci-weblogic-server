# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

# If any of the existing stacks is the same stack compartment is already using the same "service_name" as the current stack, then fail the validation.
# To pass the validation, recreate the stack with a different service name.
# This is to prevent trying to create another compute instance using the same prefix, which will lead to DNS issues.
# This validation is applicable only for resource manager stacks. Not applicable for terraform CLI mode.

data "oci_resourcemanager_stacks" "all_stacks_in_the_compartment" {
  compartment_id = var.compartment_id
}

# collect id of each stack
locals {
  stack_list = data.oci_resourcemanager_stacks.all_stacks_in_the_compartment.stacks
  num_stacks = length(local.stack_list)
  stack_ids  = [for stack in local.stack_list : { id = stack.id }]
}

# get details of each stack from the list of stack_ids
data "oci_resourcemanager_stack" "all_stacks" {
  count = local.num_stacks
  #Required
  stack_id = local.stack_ids[count.index].id
}

locals {
  stack_variables                       = [for stack in data.oci_resourcemanager_stack.all_stacks : { variables = stack.variables }]
  service_names_used_by_existing_stacks = [for stack_variables in local.stack_variables : lookup(stack_variables.variables, "service_name", "?_not_found_?")]
  duplicate_service_names_list          = [for service_name in local.service_names_used_by_existing_stacks : service_name if service_name == var.service_name]
  # There will be always one entry for the name of the current stack. Set duplicate to true if there are more than one entries.
  service_name_already_exists               = length(local.duplicate_service_names_list) > 1 ? true : false
  service_name_already_exists_msg           = "WLSC-ERROR: Another stack with the service_name [${var.service_name}] already exisits in the stack compartment. Try again with a different service name."
  validate_service_name_is_not_already_used = local.service_name_already_exists ? local.validators_msg_map[local.service_name_already_exists_msg] : null
}
