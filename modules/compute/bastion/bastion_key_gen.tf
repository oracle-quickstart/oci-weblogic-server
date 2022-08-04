
resource "tls_private_key" "bastion_opc_key" {
  count     = ! var.is_bastion_instance_required ? 0 : var.use_existing_subnet ? var.vm_count : 1
  algorithm = "RSA"
  rsa_bits  = 4096
}