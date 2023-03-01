# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "null_resource" "validate_network" {
  provisioner "local-exec" {
    command = "chmod +x ./scripts/network_validation.sh && ./scripts/network_validation.sh ${local.validation_script_wls_subnet_param}"
    interpreter = ["/bin/bash", "-c"]
    working_dir = path.module
  }
}
