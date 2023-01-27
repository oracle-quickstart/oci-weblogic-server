# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "tls_private_key" "oracle_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "tls_private_key" "opc_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
