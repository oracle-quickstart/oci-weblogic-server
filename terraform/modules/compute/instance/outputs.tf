# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

output "instance_private_ips" {
  value       = [for b in oci_core_instance.these : b.private_ip]
  description = "The private IP of each compute instance"
}

output "instance_public_ips" {
  value       = [for b in oci_core_instance.these : b.public_ip]
  description = "The public IP of each compute instance"
}

output "instance_ids" {
  value       = [for b in oci_core_instance.these : b.id]
  description = "The OCID of each compute instance"
}

output "display_names" {
  value       = [for b in oci_core_instance.these : b.display_name]
  description = "The display name of each compute instance"
}

output "instance_shapes" {
  value       = [for b in oci_core_instance.these : b.shape]
  description = "The shape of each compute instance"
}

output "availability_domains" {
  value       = [for b in oci_core_instance.these : b.availability_domain]
  description = "The availability domain of each compute instance"
}