# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  bastion_public_ssh_key  = var.use_existing_subnet ? tls_private_key.bastion_opc_key[var.vm_count - 1].public_key_openssh : tls_private_key.bastion_opc_key[0].public_key_openssh
  bastion_private_ssh_key = var.use_existing_subnet ? tls_private_key.bastion_opc_key[var.vm_count - 1].private_key_pem : tls_private_key.bastion_opc_key[0].private_key_pem
}
