# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {

  #fss related validations
  missing_mnt_compartment_id_msg       = "WLSC-ERROR: The value for mount target compartment id is required if existing mount target is used for file system"
  validate_mount_target_compartment_id = var.mount_target_id != "" && var.mount_target_compartment_id == "" ? local.validators_msg_map[local.missing_mnt_compartment_id_msg] : null

  missing_mount_target_subnet_cidr_msg      = "WLSC-ERROR: The value for mount target subnet cidr is required if file system is required"
  validate_missing_mount_target_subnet_cidr = var.add_fss && var.mount_target_id == "" && var.mount_target_subnet_id == "" && var.mount_target_subnet_cidr == "" ? local.validators_msg_map[local.missing_mount_target_subnet_cidr_msg] : null

  invalid_availability_domain_msg        = "WLSC-ERROR: The existing mount target and file system should be on same availability domain"
  validate_fss_mount_availability_domain = var.add_fss && (var.existing_fss_id != "" && var.mount_target_id != "") && (var.fss_availability_domain != var.mount_target_availability_domain) ? local.validators_msg_map[local.invalid_availability_domain_msg] : null

  missing_mount_target_subnet_id_msg      = "WLSC-ERROR: The value for mount target subnet id is required if existing subnets are required"
  validate_missing_mount_target_subnet_id = var.add_fss && var.use_existing_subnets && var.mount_target_subnet_id == "" && var.mount_target_subnet_cidr != "" ? local.validators_msg_map[local.missing_mount_target_subnet_id_msg] : null
 
  invalid_existing_fss_id_msg        = "WLSC-ERROR: The existing file system should belongs to the fss availability domain"
  validate_fss_mount_availability_domain = var.add_fss && var.existing_fss_id != "" && (var.existing_fss_id != data.oci_file_storage_file_systems.file_systems[0].file_systems[0].id) ? local.validators_msg_map[local.invalid_availability_domain_msg] : null
}

