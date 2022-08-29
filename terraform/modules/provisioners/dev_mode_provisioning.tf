# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "null_resource" "dev_mode_provisioning" {
  count = var.mode=="DEV" ? var.num_vm_instances : 0

  // In production we will use the vmscripts.tar.gz already on the image.
  // In developer mode we will upload the vmscripts to the instance.

  provisioner "file" {
    source      = var.wlsoci_vmscripts_zip_bundle_path
    destination = "/tmp/wlsoci-vmscripts.zip"

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
  }
  provisioner "remote-exec" {
    connection {
      agent               = false
      timeout             = "30m"
      host                = var.host_ips[count.index]
      user                = "opc"
      private_key         = var.ssh_private_key
      bastion_user        = "opc"
      bastion_private_key = var.bastion_host_private_key
      bastion_host        = var.bastion_host
    }

    inline = [
      "sudo unzip  /tmp/wlsoci-vmscripts.zip -d /",
      "sudo chown -R oracle:oracle /opt",
      "sudo chmod +x /opt/scripts/*.sh",
      "sudo mkdir -p /u01",

      # In dev mode, both provStartMarker and devModeMarker will need to be available on VM
      # before the provisioning will start.
      "sudo touch /u01/devModeMarker",
    ]
  }
}
