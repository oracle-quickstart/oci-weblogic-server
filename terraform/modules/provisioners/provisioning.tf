# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "null_resource" "status_check" {
  count      = var.num_vm_instances
  depends_on = [null_resource.dev_mode_provisioning]

  // Connection setup for all WLS instances
  connection {
    agent       = false
    timeout     = "30m"
    host        = var.is_bastion_instance_required ? var.host_ips[count.index] : data.oci_resourcemanager_private_endpoint_reachable_ip.private_endpoint_ips[count.index].ip_address
    user        = "opc"
    private_key = var.ssh_private_key
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
  count      = var.num_vm_instances
  depends_on = [null_resource.status_check]

  // Connection setup for all WLS instances
  connection {
    agent       = false
    timeout     = "30m"
    host        = var.is_bastion_instance_required ? var.host_ips[count.index] : data.oci_resourcemanager_private_endpoint_reachable_ip.private_endpoint_ips[count.index].ip_address
    user        = "opc"
    private_key = var.ssh_private_key
  }

  provisioner "remote-exec" {
    inline = [
      "sudo /opt/scripts/service_info.sh",
    ]
  }

}

resource "null_resource" "cleanup" {
  count      = var.num_vm_instances
  depends_on = [null_resource.print_service_info]


  // Connection setup for all WLS instances
  connection {
    agent       = false
    timeout     = "30m"
    host        = var.is_bastion_instance_required ? var.host_ips[count.index] : data.oci_resourcemanager_private_endpoint_reachable_ip.private_endpoint_ips[count.index].ip_address
    user        = "opc"
    private_key = var.ssh_private_key
  }

  provisioner "remote-exec" {
    inline = [
      "sudo /opt/scripts/delete_keys.sh",
    ]
  }
}
