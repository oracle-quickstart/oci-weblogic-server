# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_core_internet_gateway" "wls_internet_gateway" {
  count          = var.create_internet_gateway ? 1 : 0
  compartment_id = var.compartment_id
  display_name   = "${var.resource_name_prefix}-internet-gateway"
  vcn_id         = var.vcn_id

  defined_tags  = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

resource "oci_core_service_gateway" "wls_service_gateway" {
  count = !var.create_service_gateway ? 0 : 1
  #Required
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  services {
    #Required
    service_id = lookup(data.oci_core_services.services.services[0], "id")
  }
  display_name  = "${var.resource_name_prefix}-service-gateway"
  defined_tags  = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

# Create nat gateway for private subnet with IDCS
resource "oci_core_nat_gateway" "wls_nat_gateway" {
  count = !var.create_nat_gateway ? 0 : 1

  #Required
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id

  #Optional
  display_name  = "${var.resource_name_prefix}-nat-gateway"
  defined_tags  = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}
