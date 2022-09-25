# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_core_vcns" "vcns" {
  #Required
  compartment_id = var.compartment_id

  #Optional
  filter {
    name   = "id"
    values = [var.vcn_id]
  }
}

data "oci_core_internet_gateways" "vcn_internet_gateways" {
  #Required
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
}

data "oci_core_services" "services" {
  filter {
    name   = "cidr_block"
    values = ["all-.*-services-in-oracle-services-network"]
    regex  = true
  }
}

data "oci_core_instance" "existing_bastion_instance" {
  count = var.is_bastion_instance_required && var.existing_bastion_instance_id != "" ? 1 : 0

  instance_id = var.existing_bastion_instance_id
}
