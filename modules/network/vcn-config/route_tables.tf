# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

/*
* Creates a new route table rules for the specified VCN.
* Also see:
*   https://www.terraform.io/docs/providers/oci/r/core_route_table.html,
*   https://www.terraform.io/docs/providers/oci/guides/managing_default_resources.html
*/

/*
* Creates route table for private subnet using internet gateway
*/

/**
* Note:
* Use this routetable if the new internet gateway was created in oci_core_internet_gateway.tf-internet-gateway
* For VCN peering support we need to update the route table rules associated with WLS.
* Terraform only allows us to update the default route table rules so when we create a new VCN we can use the
* default route table in the VCN. This will not impact the behavior if VCN peering is not used.
*/

/**
* Note:
* Use this routetable if the internet gateway exists
* It uses the existing internet gateway id
*/
resource "oci_core_route_table" "wls_route_table" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "${var.resource_name_prefix}-${var.route_table_name}"

  dynamic "route_rules" {
    for_each = concat(oci_core_internet_gateway.wls_internet_gateway.*.id, data.oci_core_internet_gateways.tf_internet_gateways.gateways.*.id)
    content {
      destination       = var.internet_gateway_destination
      destination_type  = "CIDR_BLOCK"
      network_entity_id = route_rules.value
    }
  }

  defined_tags  = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags
}

/*
* Creates route table for private subnet using nat (only for idcs) and service gateway
*/
resource "oci_core_route_table" "wls_gateway_route_table_vcn" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "${var.resource_name_prefix}-${var.route_table_name}"

  dynamic "route_rules" {
    for_each = concat(oci_core_nat_gateway.wls_nat_gateway_vcn.*.id,data.oci_core_nat_gateways.tf_nat_gateways.nat_gateways.*.id)
    content {
      destination       = "0.0.0.0/0"
      destination_type  = "CIDR_BLOCK"
      network_entity_id = route_rules.value
    }
  }

  dynamic "route_rules" {
    for_each = concat(oci_core_service_gateway.wls_service_gateway_vcn.*.id,data.oci_core_service_gateways.tf_service_gateways.service_gateways.*.id)
    content {
      destination       = lookup(data.oci_core_services.tf_services.services[0], "cidr_block")
      destination_type  = "SERVICE_CIDR_BLOCK"
      network_entity_id = route_rules.value
    }
  }

  defined_tags  = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags
}
