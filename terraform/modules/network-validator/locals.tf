# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  validation_script_wls_subnet_param = var.wls_subnet_id != "" ? format("--wlssubnet %s", var.wls_subnet_id) : ""
  validation_script_bastion_subnet_param = var.bastion_subnet_id != "" ? format("--bastionsubnet %s", var.bastion_subnet_id) : ""
  validation_script_lb_subnet_1_param = var.lb_subnet_1_id != "" ? format("--lbsubnet %s", var.lb_subnet_1_id) : ""
  validation_script_fss_subnet_param = var.fss_subnet_id != "" ? format("--fsssubnet %s", var.fss_subnet_id) : ""
  validation_script_bastion_ip_param = var.fss_subnet_id != "" ? format("--bastionip %s", var.bastion_ip) : ""
  validation_script_atp_db_id_param = var.atp_db_id != "" ? format("--atpdbid %s", var.atp_db_id) : ""
  validation_script_oci_db_id_param = var.oci_db_database_id != "" ? format("--ocidbid %s", var.oci_db_database_id) : ""
}
