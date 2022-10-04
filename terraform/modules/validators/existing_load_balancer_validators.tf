# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  use_existing_load_balancer          = var.add_load_balancer && var.existing_load_balancer_id != ""
  invalid_existing_lb_compartment_msg = "WLSC-ERROR: No load balancer [${var.existing_load_balancer_id}] in the compartment [${var.network_compartment_id}]"
  validate_existing_lb_compartment    = local.use_existing_load_balancer && !var.existing_load_balancer_found ? local.validators_msg_map[local.invalid_existing_lb_compartment_msg] : null

  existing_lb_must_use_existing_subnets_msg      = "WLSC-ERROR: An existing load balancer can be used only with existing subnets."
  validate_existing_lb_must_use_existing_subnets = local.use_existing_load_balancer && !var.use_existing_subnets ? local.validators_msg_map[local.existing_lb_must_use_existing_subnets_msg] : null

  lb_subnet_1_id_from_datasource = [for subnet in data.oci_core_subnets.existing_vcn_subnets_data_source.subnets[*] : subnet.id if subnet.id == var.existing_lb_subnet_1_id]
  # set to true if lb subnet_1 is present in the list of subnet for the existing vcn of the stack
  valid_existing_lb_subnet_1 = local.use_existing_load_balancer && local.lb_subnet_1_id_from_datasource != "" ? local.lb_subnet_1_id_from_datasource != "" : false

  existing_lb_subnet_1_not_in_existing_vcn_of_stack_msg = "WLSC-ERROR: The load balancer [${var.existing_load_balancer_id}] subnet_1 [${var.existing_lb_subnet_1_id}] is not in the the existing vcn [${var.existing_vcn_id}] for the stack"
  validate_existing_lb_vcn_subnet_1                     = local.use_existing_load_balancer && !local.valid_existing_lb_subnet_1 ? local.validators_msg_map[local.existing_lb_subnet_1_not_in_existing_vcn_of_stack_msg] : null

  lb_subnet_2_id_from_datasource = [for subnet in data.oci_core_subnets.existing_vcn_subnets_data_source.subnets[*] : subnet.id if subnet.id == var.existing_lb_subnet_2_id]
  # set to true if lb subnet_2 is present in the list of subnet for the existing vcn of the stack
  valid_existing_lb_subnet_2 = local.use_existing_load_balancer && local.lb_subnet_2_id_from_datasource != "" ? local.lb_subnet_2_id_from_datasource != "" : false

  existing_lb_subnet_2_not_in_existing_vcn_of_stack_msg = "WLSC-ERROR: The load balancer [${var.existing_load_balancer_id}] subnet_2 [${var.existing_lb_subnet_2_id}] is not in the the existing vcn [${var.existing_vcn_id}] for the stack"
  validate_existing_lb_vcn_subnet_2                     = local.use_existing_load_balancer && !local.valid_existing_lb_subnet_2 ? local.validators_msg_map[local.existing_lb_subnet_2_not_in_existing_vcn_of_stack_msg] : null

  # verify that the backend set name is non-empty
  backendset_name_not_specified_msg     = "WLSC-ERROR: Backend set name is empty. Provide the backendset_name_for_existing_load_balancer [${var.existing_load_balancer_id}] and try again"
  validate_backendset_name_is_specified = local.use_existing_load_balancer && var.backendset_name_for_existing_load_balancer == "" ? local.validators_msg_map[local.backendset_name_not_specified_msg] : null

  # verify that the backend set belongs to the existing load balancer (always returns true if lb is not existing lb)
  enable_backendset_validation    = local.use_existing_load_balancer && var.backendset_name_for_existing_load_balancer != ""
  backendset_name_from_datasource = local.enable_backendset_validation ? [for backendset in data.oci_load_balancer_backend_sets.existing_load_balancer_backend_set_data_source.backendsets[*] : backendset.name if backendset.name == var.backendset_name_for_existing_load_balancer] : [""]
  valid_backend_set_name          = local.enable_backendset_validation ? element(concat(local.backendset_name_from_datasource, [""]), 0) != "" : true

  backendset_not_in_existing_load_balancer_msg     = "WLSC-ERROR: The load balancer [${var.existing_load_balancer_id}] does not have the backend set [${var.backendset_name_for_existing_load_balancer}]"
  validate_backendset_is_in_existing_load_balancer = local.use_existing_load_balancer && !local.valid_backend_set_name ? local.validators_msg_map[local.backendset_not_in_existing_load_balancer_msg] : null

}
