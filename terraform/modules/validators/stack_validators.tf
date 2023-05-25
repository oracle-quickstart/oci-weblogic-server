# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

# The validation fails if any running/stopped compute instances with the display name "<service_name>-wls-0" are present in the stack compartment.

data "oci_core_instances" "wls_running_instances_in_stack_compartment" {
  compartment_id = var.compartment_id
  display_name = local.instance_name_to_match
  state = "RUNNING"
}

data "oci_core_instances" "wls_stopped_instances_in_stack_compartment" {
  compartment_id = var.compartment_id
  display_name = local.instance_name_to_match
  state = "STOPPED"
}

locals {
  vnic_prefix = "wls"
  resource_name_prefix = var.service_name
  # The host_label value below should match with the host_label of the module wls_compute
  host_label = "${local.resource_name_prefix}-${local.vnic_prefix}"
  instance_name_to_match = "${local.host_label}-0"
  num_running_instances = length(data.oci_core_instances.wls_running_instances_in_stack_compartment.instances)
  num_stopped_instances = length(data.oci_core_instances.wls_stopped_instances_in_stack_compartment.instances)
  num_instances = local.num_running_instances + local.num_stopped_instances
  service_name_already_exists = local.num_instances > 0 ? true : false
  service_name_already_exists_msg = "WLSC-ERROR: Another compute instance with the name [${local.instance_name_to_match}] already exisits in the stack compartment. Try again with a different service name."
  validate_service_name_is_not_already_used = local.service_name_already_exists ? local.validators_msg_map[local.service_name_already_exists_msg] : null
}
