output "wls-loadbalancer-reservedip_id" {
  value       = oci_load_balancer_load_balancer.wls-loadbalancer-reservedip.*.id
  description = "The Ocid of the pre-created public IP of the load balancer"
}

output "wls-loadbalancer_id" {
  value       = oci_load_balancer_load_balancer.wls-loadbalancer.*.id
  description = "The Ocid of the load balancer"
}

output "wls-loadbalancer-reservedip_ip_addresses" {
  value       = oci_load_balancer_load_balancer.wls-loadbalancer-reservedip.*.ip_addresses
  description = "The list of IP addresses of the reserved IP of the load balancer"
}

output "wls-loadbalancer_ip_addresses" {
  value       = oci_load_balancer_load_balancer.wls-loadbalancer.*.ip_addresses
  description = "The list of IP addresses of the load balancer"
}
