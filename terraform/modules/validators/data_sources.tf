# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_core_subnets" "existing_vcn_subnets_data_source" {
  compartment_id = var.network_compartment_id
  vcn_id = var.existing_vcn_id
}

data "oci_load_balancer_backend_sets" "existing_load_balancer_backend_set_data_source" {
  load_balancer_id = local.use_existing_load_balancer ?  var.existing_load_balancer_id : "not_applicable"
}