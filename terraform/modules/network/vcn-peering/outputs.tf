# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

output "wls_vcn_dns_resolver_from_association" {
  value = data.oci_core_vcn_dns_resolver_association.wls_vcn_resolver_association[*].dns_resolver_id
}

output "wls_vcn_dns_resolver_id" {
  value = oci_dns_resolver.wls_oci_dsn_resolver[*].id
}

output "wls_vcn_public_route_table_attachment_id" {
  value = oci_core_route_table_attachment.wls_public_route_table_attachment[*].id
}

output "wls_vcn_private_route_table_attachment_id" {
  value = oci_core_route_table_attachment.wls_private_route_table_attachment[*].id
}