
output "id" {
  value       = oci_core_instance.wls-bastion-instance.*.id
  description = "The OCID of the created bastion compute instance"
}

output "display_name" {
  value       = oci_core_instance.wls-bastion-instance.*.display_name
  description = "The display name of the created bastion compute instance"
}

output "public_ip" {
  value       = var.is_bastion_with_reserved_public_ip ? oci_core_public_ip.reserved_public_ip.*.ip_address : oci_core_instance.wls-bastion-instance.*.public_ip
  description = "The public IP of the created bastion instance"
}

output "private_ip" {
  value       = oci_core_instance.wls-bastion-instance.*.private_ip
  description = "The private IP of the created bastion instance"
}

output "bastion_private_ssh_key" {
  value       = local.bastion_private_ssh_key
  description = "The private key data in PEM (RFC 1421) format that can be used to ssh as opc user to the bastion instance"
}