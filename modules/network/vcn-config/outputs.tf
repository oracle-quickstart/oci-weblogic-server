# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

/* Security list ids*/
output "wls_security_list_id" {
  description = "OCID of security list for WLS or bastion subnet. "
  value       = compact(concat(oci_core_security_list.wls_security_list.*.id, tolist([""])))
}

output "wls_internal_security_list_id" {
  description = "OCID of security list for WLS public subnet. "
  value       = compact(concat(oci_core_security_list.wls_internal_security_list.*.id, tolist([""])))
}

output "wls_ms_security_list_id" {
  description = "OCID of security list for WLS or bastion subnet. "
  value       = compact(concat(oci_core_security_list.wls_ms_security_list.*.id, tolist([""])))
}

output "lb_security_list_id" {
  description = "OCID of security list for LB subnet. "
  value       = compact(concat(oci_core_security_list.lb_security_list.*.id, tolist([""])))
}

output "wls_bastion_security_list_id" {
  description = "OCID of security list for WLS private subnet. "
  value       = compact(concat(oci_core_security_list.wls_bastion_security_list.*.id, oci_core_security_list.wls_existing_bastion_security_list.*.id))
}

output "fss_security_list_id" {
  description = "OCID of security list for FSS subnet. "
  value       = compact(concat(oci_core_security_list.fss_security_list.*.id, tolist([""])))
}

/* Route tables*/

output "route_table_id" {
  description = "OCID of route table with internet gateway. "
  value       = concat(coalescelist(oci_core_default_route_table.wls_default_route_table1.*.id, oci_core_route_table.wls_route_table2.*.id, tolist([""])), tolist([""]))
}

output "service_gateway_route_table_id" {
  description = "OCID of route table with service gateway. "
  value       = element(coalescelist(oci_core_route_table.wls_gateway_route_table_newvcn.*.id, oci_core_route_table.wls_gateway_route_table_existingvcn.*.id, tolist([""])), 0)
}

/* DHCP OPTIONS */
output "dhcp_options_id" {
  description = "OCID of DHCP options. "
  value       = element(coalescelist(oci_core_dhcp_options.wls_dhcp_options1.*.id, tolist([""])), 0)
}

/* Gateways */
output "wls_internet_gateway_id" {
  description = "OCID of internet gateway"
  value       = join("", oci_core_internet_gateway.wls_internet_gateway.*.id)
}

output "wls_service_gateway_services_id" {
  description = "OCID of service gateway"
  value       = join("", oci_core_service_gateway.wls_service_gateway_newvcn.*.id)
}

output "wls_nat_gateway_services_id" {
  description = "OCID of nat gateway"
  value       = join("", oci_core_nat_gateway.wls_nat_gateway_newvcn.*.id)
}
