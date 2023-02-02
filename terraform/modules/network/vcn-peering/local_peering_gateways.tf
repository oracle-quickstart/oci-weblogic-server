# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_core_local_peering_gateway" "wls_local_peering_gateway" {
  compartment_id = var.wls_network_compartment_id
  vcn_id         = var.wls_vcn_id
  display_name   = "${var.resource_name_prefix}-wls-lpg"

  #Peer WebLogic and OCI DB LPGs
  peer_id = var.db_vcn_lpg_id

  defined_tags  = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags

  # Prevent tag changes for apply after stack is created
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}


# Creates route table for public subnet using internet gateway (if the VCN is created with the stack, an internet gateway is created.
# If using an existing VCN, an internet gateway must exist in the VCN) and LPG
# This route table is attached to WLSC instances (in case of public subnet only)

resource "oci_core_route_table" "wls_public_route_table" {
  count = var.is_wls_subnet_public ? 1 : 0

  compartment_id = var.wls_network_compartment_id
  vcn_id         = var.wls_vcn_id
  display_name   = "${var.resource_name_prefix}-lpg-public-routetable"

  route_rules {
    destination       = data.oci_core_subnet.db_subnet.cidr_block
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_local_peering_gateway.wls_local_peering_gateway.id
  }

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = var.wls_internet_gateway_id
  }

  defined_tags  = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags

  # Prevent tag changes for apply after stack is created
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

resource "oci_core_route_table_attachment" "wls_public_route_table_attachment" {
  count          = var.is_wls_subnet_public ? 1 : 0
  subnet_id      = var.wls_subnet_id
  route_table_id = oci_core_route_table.wls_public_route_table[0].id
}

# Creates route table for private subnet using service gateway (is the VCN is created with the stack, a service gateway is created.
# If using an existing VCN, a service gateway must exist in the VCN) and LPG
# This route table is attached to WLSC instances (in case of private subnet only)
resource "oci_core_route_table" "wls_private_route_table" {
  count = !var.is_wls_subnet_public ? 1 : 0

  compartment_id = var.wls_network_compartment_id
  vcn_id         = var.wls_vcn_id
  display_name   = "${var.resource_name_prefix}-lpg-private-routetable"

  route_rules {
    destination       = data.oci_core_subnet.db_subnet.cidr_block
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_local_peering_gateway.wls_local_peering_gateway.id
  }

  route_rules {
    destination       = data.oci_core_services.tf_services.services[0].cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = var.wls_service_gateway_id
  }

  defined_tags  = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags

  # Prevent tag changes for apply after stack is created
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

resource "oci_core_route_table_attachment" "wls_private_route_table_attachment" {
  count          = !var.is_wls_subnet_public ? 1 : 0
  subnet_id      = var.wls_subnet_id
  route_table_id = oci_core_route_table.wls_private_route_table[0].id
}