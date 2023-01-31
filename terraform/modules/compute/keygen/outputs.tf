# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

output "opc_keys" {
  value       = tomap({ "public_key_openssh" = tls_private_key.opc_key.public_key_openssh, "private_key_pem" = tls_private_key.opc_key.private_key_pem })
  description = "A map with the public and private key (in pem format) generated for the opc user"
}

output "oracle_keys" {
  value       = tomap({ "public_key_openssh" = tls_private_key.oracle_key.public_key_openssh, "private_key_pem" = tls_private_key.oracle_key.private_key_pem })
  description = "A map with the public and private key (in pem format) generated for the oracle user"
}