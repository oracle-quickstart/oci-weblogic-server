
output "wls_loadbalancer_id" {
  value       = oci_load_balancer_load_balancer.wls_loadbalancer.id
  description = "The OCID of the load balancer"
}

output "wls_loadbalancer_ip_addresses" {
  value       = oci_load_balancer_load_balancer.wls_loadbalancer.ip_addresses
  description = "The list of IP addresses of the load balancer"
}
