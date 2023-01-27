# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

output "wls_version" {
  value       = var.wls_version
  description = "The WebLogic version installed in the compute instances"
}

output "instance_private_ips" {
  value       = coalescelist(module.wls-instances.instance_private_ips, tolist([""]))
  description = "The private IP of each WebLogic compute instance"
}

output "instance_public_ips" {
  value       = coalescelist(module.wls-instances.instance_public_ips, tolist([""]))
  description = "The public IP of each WebLogic compute instance"
}

output "instance_ids" {
  value       = coalescelist(module.wls-instances.instance_ids, tolist([""]))
  description = "The OCID of each WebLogic compute instance"
}

output "display_names" {
  value       = coalescelist(module.wls-instances.display_names, tolist([""]))
  description = "The display name of each WebLogic compute instance"
}

output "instance_shapes" {
  value       = coalescelist(module.wls-instances.instance_shapes, tolist([""]))
  description = "The shape of each WebLogic compute instance"
}

output "availability_domains" {
  value       = coalescelist(module.wls-instances.availability_domains, tolist([""]))
  description = "The availability domain of each WebLogic compute instance"
}

output "ssh_private_key_opc" {
  value       = module.compute-keygen.opc_keys["private_key_pem"]
  description = "The ssh private key in PEM format generated for the opc user"
}