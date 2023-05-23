# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

# list all stacks in all states (active, deleted etc)
data "oci_resourcemanager_stacks" "all_stacks_in_the_compartment" {
  compartment_id = var.compartment_id
}

locals {
  stack_list = data.oci_resourcemanager_stacks.all_stacks_in_the_compartment.stacks
  num_stacks = length(local.stack_list)
  stack_ids = [for stack in local.stack_list : { id = stack.id }]
}

# get details of each stack
data "oci_resourcemanager_stack" "all_stacks" {
  count = local.num_stacks
  #Required
  stack_id = local.stack_ids[count.index].id
}

locals {
  stack_variables = [for stack in data.oci_resourcemanager_stack.all_stacks : { variables = stack.variables }]
  service_names_used_by_existing_stacks = [for stack_variables in local.stack_variables : lookup(stack_variables.variables, "service_name", "?service_name_attribute_not_found?")]
  service_name_already_exists = contains(local.service_names_used_by_existing_stacks, var.service_name) ? true : false
  service_name_already_exists_msg      = "WLSC-ERROR: The stack with the service_name [${var.service_name}] already exisits in the stack compartment. Try again with a different service name."
  validate_service_name_is_not_already_used = local.service_name_already_exists ? local.validators_msg_map[local.service_name_already_exists_msg] : null
}
