# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

/* Route tables*/

output "route_table_id" {
  description = "OCID of route table with internet gateway. "
  value       = oci_core_route_table.wls_route_table.id
}

output "service_gateway_route_table_id" {
  description = "OCID of route table with service gateway. "
  value       = oci_core_route_table.wls_gateway_route_table.id
}

/* DHCP OPTIONS */
output "dhcp_options_id" {
  description = "OCID of DHCP options. "
  value       = oci_core_dhcp_options.wls_dhcp_options.id
}

/* Gateways */
output "wls_internet_gateway_id" {
  description = "OCID of internet gateway"
  value       = join("", oci_core_internet_gateway.wls_internet_gateway.*.id)
}

output "wls_service_gateway_services_id" {
  description = "OCID of service gateway"
  value       = join("", oci_core_service_gateway.wls_service_gateway.*.id)
}

output "wls_nat_gateway_services_id" {
  description = "OCID of nat gateway"
  value       = join("", oci_core_nat_gateway.wls_nat_gateway.*.id)
}
