# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

/*
* Creates a new internet gateway and service-gateway(private subnet) for the specified VCN.
* Note:If existing vcn has to be used, then it has to have precreated internet gateway
* Also see:
*   https://www.terraform.io/docs/providers/oci/r/core_internet_gateway.html
*   https://www.terraform.io/docs/providers/oci/r/core_nat_gateway.html
*/


resource "oci_core_internet_gateway" "wls_internet_gateway" {
  compartment_id = var.compartment_id
  display_name   = "${var.resource_name_prefix}-internet-gateway"
  vcn_id         = var.vcn_id

  defined_tags  = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags
}

resource "oci_core_service_gateway" "wls_service_gateway_vcn" {
  count = length(data.oci_core_service_gateways.tf_service_gateways.service_gateways.*.id) >0 ? 0:1
  #Required
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  services {
    #Required
    service_id = lookup(data.oci_core_services.tf_services.services[0], "id")
  }
  display_name  = "${var.resource_name_prefix}-service-gateway"
  defined_tags  = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags
}

# Create nat gateway for private subnet with IDCS
resource "oci_core_nat_gateway" "wls_nat_gateway_vcn" {
  count = length(data.oci_core_nat_gateways.tf_nat_gateways.nat_gateways.*.id) >0 ? 0:1

  #Required
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id

  #Optional
  display_name  = "${var.resource_name_prefix}-nat-gateway"
  defined_tags  = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags
}
