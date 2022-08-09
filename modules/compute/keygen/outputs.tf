output "opc_keys" {
  value       = tomap({ "public_key_openssh" = tls_private_key.opc_key.public_key_openssh, "private_key_pem" = tls_private_key.opc_key.private_key_pem })
  description = "A map with the public and private key (in pem format) generated for the opc user"
}

output "oracle_keys" {
  value       = tomap({ "public_key_openssh" = tls_private_key.oracle_key.public_key_openssh, "private_key_pem" = tls_private_key.oracle_key.private_key_pem })
  description = "A map with the public and private key (in pem format) generated for the oracle user"
}