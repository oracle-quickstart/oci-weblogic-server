# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_identity_regions" "home_region" {
  filter {
    name   = "key"
    values = [data.oci_identity_tenancy.tenancy.home_region_key]
  }
}

data "oci_identity_tenancy" "tenancy" {
  tenancy_id = var.tenancy_id
}

data "oci_core_instance" "existing_bastion_instance" {
  count = var.existing_bastion_instance_id != "" ? 1 : 0

  instance_id = var.existing_bastion_instance_id
}

data "oci_core_subnet" "wls_subnet" {
  count     = var.wls_subnet_id == "" ? 0 : 1
  subnet_id = var.wls_subnet_id
}

data "oci_core_subnet" "bastion_subnet" {
  count     = var.bastion_subnet_id == "" ? 0 : 1
  subnet_id = var.bastion_subnet_id
}

data "template_file" "ad_names" {
  count    = length(data.oci_identity_availability_domains.ADs.availability_domains)
  template = (length(regexall("^.*Flex", var.instance_shape)) > 0 || length(regexall("^BM.*", var.instance_shape)) > 0 || (tonumber(lookup(data.oci_limits_limit_values.compute_shape_service_limits[count.index].limit_values[0], "value")) > 0)) ? lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index], "name") : ""
}

data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_id
}

data "oci_limits_limit_values" "compute_shape_service_limits" {
  count = length(data.oci_identity_availability_domains.ADs.availability_domains)
  #Required
  compartment_id = var.tenancy_id
  service_name   = "compute"

  #Optional
  availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index], "name")
  #format of name field -vm-standard2-2-count
  #ignore flex shapes
  name = length(regexall("^.*Flex", var.instance_shape)) > 0 || length(regexall("^BM.*", var.instance_shape)) > 0 ? "" : format("%s-count", replace(var.instance_shape, ".", "-"))
}

data "oci_load_balancer_load_balancers" "existing_load_balancers_data_source" {
  compartment_id = var.compartment_id
}

data "oci_core_nat_gateways" "nat_gateways" {
  #count = var.wls_existing_vcn_id=="" ? 0 : 1
  #Required
  compartment_id = var.compartment_id

  #Optional
  vcn_id = local.vcn_id
}

data "oci_core_service_gateways" "service_gateways" {
  #count = var.wls_existing_vcn_id=="" ? 0 : 1
  #Required
  compartment_id = var.compartment_id

  #Optional
  vcn_id = local.vcn_id
}
