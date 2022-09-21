# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

output "resolver_from_association" {
  value = data.oci_core_vcn_dns_resolver_association.wls_vcn_resolver_association[*].dns_resolver_id
}
