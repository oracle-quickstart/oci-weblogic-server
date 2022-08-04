locals {
  ocpus                   = length(regexall("^.*Flex", var.instance_shape)) > 0 ? var.ocpu_count : lookup(data.oci_core_shapes.oci_shapes.shapes[0], "ocpus")
  bastion_public_ssh_key  = ! var.is_bastion_instance_required ? "" : var.use_existing_subnet ? tls_private_key.bastion_opc_key[var.vm_count - 1].public_key_openssh : tls_private_key.bastion_opc_key[0].public_key_openssh
  bastion_private_ssh_key = ! var.is_bastion_instance_required ? "" : var.use_existing_subnet ? tls_private_key.bastion_opc_key[var.vm_count - 1].private_key_pem : tls_private_key.bastion_opc_key[0].private_key_pem
}