# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "null_resource" "validate_network" {
  provisioner "local-exec" {
    command = "chmod +x ./scripts/network_validation.sh && ./scripts/network_validation.sh ${local.validation_script_wls_subnet_param} ${local.validation_script_bastion_subnet_param} ${local.validation_script_bastion_ip_param} ${local.validation_script_lb_subnet_1_param} ${local.validation_script_lb_subnet_2_param} ${local.validation_script_wls_lb_port} ${local.validation_script_mount_target_subnet_param} ${local.validation_script_atp_db_id_param} ${local.validation_script_oci_db_id_param} ${local.validation_script_oci_db_port_param} ${local.validation_script_lpg_id_param} ${local.validation_script_http_port_param} ${local.validation_script_https_port_param} ${local.validation_script_existing_admin_server_nsg_id_param} ${local.validation_script_existing_managed_server_nsg_id_param} ${local.validation_script_existing_lb_nsg_id_param} ${local.validation_script_existing_mount_target_nsg_id_param} ${local.validation_script_existing_bastion_nsg_id_param}"
    interpreter = ["/bin/bash", "-c"]
    working_dir = path.module
  }
}
