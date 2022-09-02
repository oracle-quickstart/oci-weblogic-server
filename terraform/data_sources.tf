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

data "oci_core_subnet" "wls_subnet" {
  count     = var.wls_subnet_id == "" ? 0 : 1
  subnet_id = var.wls_subnet_id
}

data "oci_core_subnet" "bastion_subnet" {
  count     = var.bastion_subnet_id == "" ? 0 : 1
  subnet_id = var.bastion_subnet_id
}

data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_id
}

data "oci_load_balancer_load_balancers" "existing_load_balancers_data_source" {
  compartment_id = var.compartment_id
}

data "oci_core_nat_gateways" "nat_gateways" {
  #Required
  compartment_id = var.compartment_id

  #Optional
  vcn_id = local.vcn_id
}

data "oci_core_service_gateways" "service_gateways" {
  #Required
  compartment_id = var.compartment_id

  #Optional
  vcn_id = local.vcn_id
}

data "oci_core_subnet" "mount_target_subnet" {
  count = var.mount_target_subnet_id == "" ? 0 : 1

  #Required
  subnet_id = var.mount_target_subnet_id
}

data "oci_file_storage_file_systems" "file_systems" {
  count = var.existing_fss_id != "" ? 1 : 0

  #Required
  availability_domain = var.fss_availability_domain
  compartment_id      = var.fss_compartment_id

  id = var.existing_fss_id
}

data "oci_file_storage_mount_targets" "mount_targets" {
  count = var.mount_target_id != "" ? 1 : 0

  #Required
  availability_domain = var.fss_availability_domain
  compartment_id      = var.mount_target_compartment_id

  id = var.mount_target_id
}


data "oci_file_storage_exports" "export" {
  count = var.existing_fss_id != "" ? 1 : 0
  id    = var.existing_export_path_id
}

data "oci_file_storage_mount_targets" "mount_target_by_export_set" {
  count = var.existing_fss_id != "" ? 1 : 0
  #Required
  availability_domain = var.fss_availability_domain
  compartment_id      = var.compartment_id
  export_set_id       = data.oci_file_storage_exports.export[0].export_set_id
}

data "oci_core_private_ip" "mount_target_private_ip" {
  count = var.existing_fss_id != "" ? 1 : 0
  #Required
  private_ip_id = data.oci_file_storage_mount_targets.mount_target_by_export_set[0].mount_targets[0].private_ip_ids[0]
}
