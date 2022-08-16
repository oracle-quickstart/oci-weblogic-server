/*
 * Copyright (c) 2019, 2021, Oracle and/or its affiliates. All rights reserved.
 */

/* Security list ids*/
output "wls_security_list_id" {
  description = "ocid of security list for WLS or bastion subnet. "
  value       = compact(concat(oci_core_security_list.wls-security-list.*.id, list("")))
}

output "wls_internal_security_list_id" {
  description = "ocid of security list for WLS public subnet. "
  value       = compact(concat(oci_core_security_list.wls-internal-security-list.*.id, list("")))
}

output "wls_ms_security_list_id" {
  description = "ocid of security list for WLS or bastion subnet. "
  value       = compact(concat(oci_core_security_list.wls-ms-security-list.*.id, list("")))
}

output "lb_security_list_id" {
  description = "ocid of security list for LB subnet. "
  value       = compact(concat(oci_core_security_list.lb-security-list.*.id, list("")))
}

output "wls_bastion_security_list_id" {
  description = "ocid of security list for WLS private subnet. "
  value       = compact(concat(oci_core_security_list.wls-bastion-security-list.*.id, oci_core_security_list.wls-existing-bastion-security-list.*.id))
}

output "fss_security_list_id" {
  description = "ocid of security list for FSS subnet. "
  value       = compact(concat(oci_core_security_list.fss-security-list.*.id, list("")))
}

/* Route tables*/

output "route_table_id" {
  description = "ocid of route table with internet gateway. "
  value       = concat(coalescelist(oci_core_default_route_table.wls-default-route-table1.*.id, oci_core_route_table.wls-route-table2.*.id, list("")), list(""))
}

output "service_gateway_route_table_id" {
  description = "ocid of route table with service gateway. "
  value       = element(coalescelist(oci_core_route_table.wls-gateway-route-table-newvcn.*.id, oci_core_route_table.wls-gateway-route-table-existingvcn.*.id, list("")), 0)
}

/* DHCP OPTIONS */
output "dhcp_options_id" {
  description = "ocid of DHCP options. "
  value       = element(coalescelist(oci_core_dhcp_options.wls-dhcp-options1.*.id, list("")), 0)
}

/* Gateways */
output "wls_internet_gateway_id" {
  description = "ocid of internet gateway"
  value       = join("", oci_core_internet_gateway.wls-internet-gateway.*.id)
}

output "wls_service_gateway_services_id" {
  description = "ocid of service gateway"
  value       = join("", oci_core_service_gateway.wls-service-gateway-newvcn.*.id)
}

output "wls_nat_gateway_services_id" {
  description = "ocid of nat gateway"
  value       = join("", oci_core_nat_gateway.wls-nat-gateway-newvcn.*.id)
}