# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

data "cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "ainit.sh"
    content_type = "text/x-shellscript"
    content      = local.key_script
  }
  part {
    filename     = "init.sh"
    content_type = "text/x-shellscript"
    content      = file(format("%s/%s", path.module, var.bootstrap_file))
  }
}
