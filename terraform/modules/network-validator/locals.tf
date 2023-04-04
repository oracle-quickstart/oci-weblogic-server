# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  validation_script_wls_subnet_param                     = var.wls_subnet_id != "" ? format("--wlssubnet %s", var.wls_subnet_id) : ""
  validation_script_bastion_subnet_param                 = var.bastion_subnet_id != "" ? format("--bastionsubnet %s", var.bastion_subnet_id) : ""
  validation_script_bastion_ip_param                     = var.bastion_ip != "" ? format("--bastionip %s", var.bastion_ip) : ""
  validation_script_lb_subnet_1_param                    = var.lb_subnet_1_id != "" ? format("--lbsubnet1 %s", var.lb_subnet_1_id) : ""
  validation_script_lb_subnet_2_param                    = var.lb_subnet_2_id != "" ? format("--lbsubnet2 %s", var.lb_subnet_2_id) : ""
  validation_script_lb_source_cidr_param                 = var.lb_source_cidr != "" ? format("--lbsourcecidr %s", var.lb_source_cidr) : ""
  validation_script_wls_lb_port                          = var.wls_ms_extern_port != "" ? format("--externalport %s", var.wls_ms_extern_port) : ""
  validation_script_mount_target_subnet_param            = var.mount_target_subnet_id != "" ? format("--fsssubnet %s", var.mount_target_subnet_id) : ""
  validation_script_atp_db_id_param                      = var.atp_db_id != "" ? format("--atpdbid %s", var.atp_db_id) : ""
  validation_script_oci_db_dbsystem_id_param             = var.oci_db_dbsystem_id != "" ? format("--ocidbid %s", var.oci_db_dbsystem_id) : ""
  validation_script_oci_db_port_param                    = var.oci_db_port != 0 ? format("--ocidbport %s", var.oci_db_port) : ""
  validation_script_http_port_param                      = var.wls_extern_admin_port != "" ? format("--http_port %s", var.wls_extern_admin_port) : ""
  validation_script_https_port_param                     = var.wls_extern_ssl_admin_port != "" ? format("--https_port %s", var.wls_extern_ssl_admin_port) : ""
  validation_script_existing_admin_server_nsg_id_param   = var.existing_admin_server_nsg_id != "" ? format("--adminsrvnsg %s", var.existing_admin_server_nsg_id) : ""
  validation_script_existing_managed_server_nsg_id_param = var.existing_managed_server_nsg_id != "" ? format("--managedsrvnsg %s", var.existing_managed_server_nsg_id) : ""
  validation_script_existing_lb_nsg_id_param             = var.existing_lb_nsg_id != "" ? format("--lbnsg %s", var.existing_lb_nsg_id) : ""
  validation_script_existing_mount_target_nsg_id_param   = var.existing_mount_target_nsg_id != "" ? format("--fssnsg %s", var.existing_mount_target_nsg_id) : ""
  validation_script_existing_bastion_nsg_id_param        = var.existing_bastion_nsg_id != "" ? format("--bastionnsg %s", var.existing_bastion_nsg_id) : ""
}
