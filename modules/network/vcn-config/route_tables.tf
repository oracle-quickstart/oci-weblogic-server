# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

/*
* Creates route table for internet gateway
*/
resource "oci_core_route_table" "wls_route_table" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "${var.resource_name_prefix}-${var.route_table_name}"

  dynamic "route_rules" {
    for_each = concat(oci_core_internet_gateway.wls_internet_gateway.*.id, data.oci_core_internet_gateways.internet_gateways.gateways.*.id)
    content {
      destination       = var.internet_gateway_destination
      destination_type  = "CIDR_BLOCK"
      network_entity_id = route_rules.value
    }
  }

  defined_tags  = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

/*
* Creates route table for private subnet using nat (only for idcs) and service gateway
*/
resource "oci_core_route_table" "wls_gateway_route_table" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "${var.resource_name_prefix}-${var.route_table_name}"

  dynamic "route_rules" {
    for_each = var.create_nat_gateway ? concat(oci_core_nat_gateway.wls_nat_gateway.*.id,var.nat_gateway_ids) : []
    content {
      destination       = "0.0.0.0/0"
      destination_type  = "CIDR_BLOCK"
      network_entity_id = route_rules.value
    }
  }

  dynamic "route_rules" {
    for_each =  concat(oci_core_service_gateway.wls_service_gateway.*.id,var.service_gateway_ids)
    content {
      destination       = lookup(data.oci_core_services.services.services[0], "cidr_block")
      destination_type  = "SERVICE_CIDR_BLOCK"
      network_entity_id = route_rules.value
    }
  }

  defined_tags  = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}
