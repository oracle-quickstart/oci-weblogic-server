# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_identity_regions" "home_region" {
  filter {
    name   = "key"
    values = [data.oci_identity_tenancy.tenancy.home_region_key]
  }
}

data "oci_identity_tenancy" "tenancy" {
  tenancy_id = var.tenancy_ocid
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

# For querying availability domains given subnet_id
data "oci_core_subnet" "lb_subnet_1_id" {
  count = var.lb_subnet_1_id == "" ? 0 : 1

  #Required
  subnet_id = var.lb_subnet_1_id
}

data "oci_core_subnet" "lb_subnet_2_id" {
  count = var.lb_subnet_2_id == "" ? 0 : 1

  #Required
  subnet_id = var.lb_subnet_2_id
}

data "template_file" "ad_names" {
  count    = length(data.oci_identity_availability_domains.ADs.availability_domains)
  template = (length(regexall("^.*Flex", local.instance_shape.instanceShape)) > 0 || length(regexall("^BM.*", local.instance_shape.instanceShape)) > 0 || (tonumber(lookup(data.oci_limits_limit_values.compute_shape_service_limits[count.index].limit_values[0], "value")) > 0)) ? lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index], "name") : ""
}

data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

data "oci_limits_limit_values" "compute_shape_service_limits" {
  count = length(data.oci_identity_availability_domains.ADs.availability_domains)
  #Required
  compartment_id = var.tenancy_ocid
  service_name   = "compute"

  #Optional
  availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index], "name")
  #format of name field -vm-standard2-2-count
  #ignore flex shapes
  name = length(regexall("^.*Flex", local.instance_shape.instanceShape)) > 0 || length(regexall("^BM.*", local.instance_shape.instanceShape)) > 0 ? "" : format("%s-count", replace(local.instance_shape.instanceShape, ".", "-"))
}

data "oci_load_balancer_load_balancers" "existing_load_balancers_data_source" {
  compartment_id = local.network_compartment_id
}

data "oci_core_nat_gateways" "nat_gateways" {
  #Required
  compartment_id = local.network_compartment_id

  #Optional
  vcn_id = local.vcn_id
}

data "oci_core_service_gateways" "service_gateways" {
  #Required
  compartment_id = local.network_compartment_id

  #Optional
  vcn_id = local.vcn_id
}

data "oci_core_internet_gateways" "internet_gateways" {
  compartment_id = local.network_compartment_id
  vcn_id         = local.vcn_id
}

data "oci_core_subnet" "mount_target_subnet" {
  count = var.mount_target_subnet_id == "" ? 0 : 1

  #Required
  subnet_id = var.mount_target_subnet_id
}

data "oci_file_storage_file_systems" "file_systems" {
  count = var.existing_fss_id != "" ? 1 : 0

  #Required
  availability_domain = local.fss_availability_domain
  compartment_id      = var.fss_compartment_id

  id = var.existing_fss_id
}

data "oci_file_storage_mount_targets" "mount_targets" {
  count = var.mount_target_id != "" ? 1 : 0

  #Required
  availability_domain = local.fss_availability_domain
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
  availability_domain = local.fss_availability_domain
  compartment_id      = var.fss_compartment_id
  export_set_id       = data.oci_file_storage_exports.export[0].export_set_id
}

data "oci_core_private_ip" "mount_target_private_ips" {
  count = var.existing_fss_id != "" ? 1 : 0
  #Required
  private_ip_id = data.oci_file_storage_mount_targets.mount_target_by_export_set[0].mount_targets[0].private_ip_ids[0]
}

data "oci_apm_apm_domain" "apm_domain" {
  count = var.use_apm_service ? 1 : 0

  #Required
  apm_domain_id = var.apm_domain_id
}

data "oci_core_vcn" "wls_vcn" {
  count = var.wls_existing_vcn_id != "" ? 1 : 0
  #Required
  vcn_id = var.wls_existing_vcn_id
}

data "oci_core_subnet" "mount_target_existing_subnet" {
  count = var.mount_target_id == "" ? 0 : 1

  #Required
  subnet_id = data.oci_file_storage_mount_targets.mount_targets[0].mount_targets[0].subnet_id
}

data "oci_core_subnet" "mount_target_existing_subnet_by_export" {
  count = var.existing_fss_id == "" ? 0 : 1

  #Required
  subnet_id = data.oci_file_storage_mount_targets.mount_target_by_export_set[0].mount_targets[0].subnet_id
}

data "oci_objectstorage_namespace" "object_namespace" {

  #Optional
  compartment_id = var.tenancy_ocid
}

data "oci_identity_regions" "all_regions" {
}

data "oci_database_autonomous_database" "atp_db" {
  count                  = local.is_atp_db ? 1 : 0
  autonomous_database_id = var.atp_db_id
}

data "oci_database_db_systems" "ocidb_db_systems" {
  count          = local.is_oci_db ? 1 : 0
  compartment_id = var.oci_db_compartment_id
  filter {
    name   = "id"
    values = [var.oci_db_dbsystem_id]
  }
}

data "oci_core_image" "ucm_image" {
  count = var.ucm_instance_image_id != "" ? 1 : 0
  #Required
  image_id = var.ucm_instance_image_id
}

data "oci_core_instances" "ucm_instances" {
  #Required
  compartment_id = var.compartment_ocid

  #filter the instances based on the UCM image and the stack prefix.
  filter {
    name   = "metadata.is_ucm_image"
    values = ["true"]
  }
  filter {
    name   = "display_name"
    values = ["${local.service_name_prefix}-wls-*"]
    regex  = true
  }
  #filter only the running instances, we need to consider stopped case also
  filter {
    name   = "state"
    values = ["RUNNING", "STOPPED"]
  }
}

data "oci_core_instances" "provisioned_instances" {
  #Required
  compartment_id = var.compartment_ocid

  #filter the instances based on stack prefix
  filter {
    name   = "display_name"
    values = ["${local.service_name_prefix}-wls-*"]
    regex  = true
  }
  #filter only the running instances, we need to consider stopped case also
  filter {
    name   = "state"
    values = ["RUNNING", "STOPPED"]
  }
}

