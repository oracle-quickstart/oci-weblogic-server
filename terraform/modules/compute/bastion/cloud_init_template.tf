# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

data "cloudinit_config" "bastion-config" {
  gzip          = true
  base64_encode = true

  # cloud-config configuration file.
  # /var/lib/cloud/instance/scripts/*

  part {
    filename     = "ainit.sh"
    content_type = "text/x-shellscript"
    content      = local.bastion_key_script
  }

  part {
    filename     = "init.sh"
    content_type = "text/cloud-config"
    content      = file(format("%s/%s", path.module, var.bastion_bootstrap_file))
  }
}
