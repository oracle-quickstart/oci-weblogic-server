# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "null_resource" "validate_network" {
  count = var.use_existing_subnets ? 1 : 0
  provisioner "local-exec" {
    command     = "chmod +x ./scripts/network_validation.sh && ./scripts/network_validation.sh ${local.validation_script_wls_subnet_param} ${local.validation_script_bastion_subnet_param} ${local.validation_script_bastion_ip_param} ${local.validation_script_lb_subnet_1_param} ${local.validation_script_lb_subnet_2_param} ${local.validation_script_wls_lb_port} ${local.validation_script_lb_source_cidr_param} ${local.validation_script_mount_target_subnet_param} ${local.validation_script_atp_db_id_param} ${local.validation_script_oci_db_dbsystem_id_param} ${local.validation_script_oci_db_port_param} ${local.validation_script_http_port_param} ${local.validation_script_https_port_param} ${local.validation_script_existing_admin_server_nsg_id_param} ${local.validation_script_existing_managed_server_nsg_id_param} ${local.validation_script_existing_lb_nsg_id_param} ${local.validation_script_existing_mount_target_nsg_id_param} ${local.validation_script_existing_bastion_nsg_id_param}"
    interpreter = ["/bin/bash", "-c"]
    working_dir = path.module
  }
}

resource "null_resource" "status_check" {
  count      = var.is_bastion_instance_required ? var.num_vm_instances : 0
  depends_on = [null_resource.dev_mode_provisioning,null_resource.validate_network]

  // Connection setup for all WLS instances
  connection {
    agent       = false
    timeout     = "30m"
    host        = var.host_ips[count.index]
    user        = "opc"
    private_key = var.ssh_private_key

    bastion_user        = "opc"
    bastion_private_key = var.bastion_host_private_key
    bastion_host        = var.bastion_host
  }

  // Call check_status.sh 11 more times - if we add additional markers we must add an additional status check call here.
  // Also see - all_markers_list in check_provisioning_status.py for the list of all existing markers.
  // It is OK to call provisioning check more times than there are markers but we should at least call it as many times
  // as there are number of marker files created on VM.

  provisioner "remote-exec" {
    inline = [
      "sudo sh /opt/scripts/check_status.sh",
      "sudo su - oracle -c 'python3 /opt/scripts/check_provisioning_status.py'",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo su - oracle -c 'python3 /opt/scripts/check_provisioning_status.py'",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo su - oracle -c 'python3 /opt/scripts/check_provisioning_status.py'",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo su - oracle -c 'python3 /opt/scripts/check_provisioning_status.py'",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo su - oracle -c 'python3 /opt/scripts/check_provisioning_status.py'",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo su - oracle -c 'python3 /opt/scripts/check_provisioning_status.py'",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo su - oracle -c 'python3 /opt/scripts/check_provisioning_status.py'",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo su - oracle -c 'python3 /opt/scripts/check_provisioning_status.py'",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo su - oracle -c 'python3 /opt/scripts/check_provisioning_status.py'",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo su - oracle -c 'python3 /opt/scripts/check_provisioning_status.py'",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo su - oracle -c 'python3 /opt/scripts/check_provisioning_status.py'",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo su - oracle -c 'python3 /opt/scripts/check_provisioning_status.py'",
    ]
  }
  provisioner "remote-exec" {
    inline = [
      "sudo su - oracle -c 'python3 /opt/scripts/check_provisioning_status.py'",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo su - oracle -c 'python3 /opt/scripts/check_provisioning_status.py'",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo su - oracle -c 'python3 /opt/scripts/check_provisioning_status.py'",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo su - oracle -c 'python3 /opt/scripts/check_provisioning_status.py'",
    ]
  }
}

resource "null_resource" "print_service_info" {
  count      = var.is_bastion_instance_required ? var.num_vm_instances : 0
  depends_on = [null_resource.status_check]

  // Connection setup for all WLS instances
  connection {
    agent       = false
    timeout     = "30m"
    host        = var.host_ips[count.index]
    user        = "opc"
    private_key = var.ssh_private_key

    bastion_user        = "opc"
    bastion_private_key = var.bastion_host_private_key
    bastion_host        = var.bastion_host
  }

  provisioner "remote-exec" {
    inline = [
      "sudo /opt/scripts/service_info.sh",
    ]
  }

}

resource "null_resource" "cleanup" {
  count      = var.is_bastion_instance_required ? var.num_vm_instances : 0
  depends_on = [null_resource.print_service_info]


  // Connection setup for all WLS instances
  connection {
    agent       = false
    timeout     = "30m"
    host        = var.host_ips[count.index]
    user        = "opc"
    private_key = var.ssh_private_key

    bastion_user        = "opc"
    bastion_private_key = var.bastion_host_private_key
    bastion_host        = var.bastion_host
  }

  provisioner "remote-exec" {
    inline = [
      "sudo /opt/scripts/delete_keys.sh",
    ]
  }
}

resource "null_resource" "cleanup_bastion" {
  count      = var.is_bastion_instance_required && var.existing_bastion_instance_id == "" && !var.assign_public_ip ? 1 : 0
  depends_on = [null_resource.cleanup]

  // Connection setup for all WLS instances
  connection {
    agent       = false
    timeout     = "30m"
    host        = var.bastion_host
    user        = "opc"
    private_key = var.bastion_host_private_key
  }

  # run this provisioner everytime new bastion is created during reapply
  triggers = {
    ip_address = var.bastion_host
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cp /home/opc/.ssh/authorized_keys.bak /home/opc/.ssh/authorized_keys",
      "rm -f /home/opc/.ssh/authorized_keys.bak",
      "chown -R opc /home/opc/.ssh/authorized_keys",
      "sudo systemctl daemon-reload",
      "sudo systemctl restart oracle-cloud-agent.service"
    ]
  }
}
