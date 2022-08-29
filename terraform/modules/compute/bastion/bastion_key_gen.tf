# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "tls_private_key" "bastion_opc_key" {
  count     = var.use_existing_subnet ? var.vm_count : 1
  algorithm = "RSA"
  rsa_bits  = 4096
}