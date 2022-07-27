output "InstancePrivateIPs" {
  value = [ for b in oci_core_instance.these : b.private_ip]
}

output "InstancePublicIPs" {
  value = [ for b in oci_core_instance.these : b.public_ip]
}

output "InstanceOcids" {
  value = [ for b in oci_core_instance.these : b.id]
}

output "display_names" {
  value = [ for b in oci_core_instance.these : b.display_name]
}

output "InstanceShapes" {
  value = [ for b in oci_core_instance.these : b.shape]
}

output "AvailabilityDomains" {
  value = [ for b in oci_core_instance.these : b.availability_domain]
}