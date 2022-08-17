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
resource "oci_core_default_route_table" "wls_default_route_table1" {
  count = (var.wls_vcn_name=="" || var.use_existing_subnets)?0:1

  //  compartment_id  = "${var.compartment_id}"
  //  vcn_id          = "${var.vcn_id}"
  //  display_name    = "${var.route_table_name}"
  manage_default_resource_id = lookup(data.oci_core_vcns.tf_vcns.virtual_networks[0],"default_route_table_id")

  route_rules {
    destination       = var.internet_gateway_destination
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.wls_internet_gateway[0].id
  }

  defined_tags = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags
}

/**
* Note:
* Use this routetable if the internet gateway exists
* It uses the existing internet gateway id
*/
resource "oci_core_route_table" "wls_route_table2" {
  count          = (var.wls_vcn_name=="" && var.use_existing_subnets==false) && !var.is_vcn_peering ?1:0
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "${var.resource_name_prefix}-${var.route_table_name}"

  route_rules {
    destination       = var.internet_gateway_destination
    destination_type  = "CIDR_BLOCK"
    network_entity_id = lookup(data.oci_core_internet_gateways.tf_internet_gateways.gateways[0], "id")
  }
  defined_tags = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags
}

/*
* Creates route table for private subnet using nat (only for idcs) and service gateway
*/
resource "oci_core_route_table" "wls_gateway_route_table_newvcn" {
  count          = !var.assign_backend_public_ip && var.wls_vcn_name!="" && !var.is_vcn_peering ?1:0
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "${var.resource_name_prefix}-${var.route_table_name}"

  dynamic "route_rules" {
    for_each = var.is_idcs_selected? list(1) : []

    content {
      destination       =  "0.0.0.0/0"
      destination_type  = "CIDR_BLOCK"
      network_entity_id = join("",oci_core_nat_gateway.wls_nat_gateway_newvcn.*.id)
    }
  }

  dynamic "route_rules" {
    for_each = list(1)

    content {
      destination       = lookup(data.oci_core_services.tf_services.services[0], "cidr_block")
      destination_type  = "SERVICE_CIDR_BLOCK"
      network_entity_id = join("",oci_core_service_gateway.wls_service_gateway_newvcn.*.id)
    }
  }

  defined_tags = var.defined_tags
  freeform_tags = var.freeform_tags
}

resource "oci_core_route_table" "wls_gateway_route_table_existingvcn" {
  count = !var.assign_backend_public_ip && var.existing_vcn_id !="" && !var.use_existing_subnets && !var.is_vcn_peering ? 1: 0
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "${var.resource_name_prefix}-${var.route_table_name}"

  dynamic "route_rules" {
    for_each = var.is_idcs_selected? list(1) : []

    content {
      destination       =  "0.0.0.0/0"
      destination_type  = "CIDR_BLOCK"
      network_entity_id = lookup(data.oci_core_nat_gateways.tf_nat_gateways.nat_gateways[0], "id")
    }
  }

  dynamic "route_rules" {
    for_each = list(1)

    content {
      destination       = lookup(data.oci_core_services.tf_services.services[0], "cidr_block")
      destination_type  = "SERVICE_CIDR_BLOCK"
      network_entity_id = lookup(data.oci_core_service_gateways.tf_service_gateways.service_gateways[0], "id")
    }
  }

  defined_tags = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags
}
