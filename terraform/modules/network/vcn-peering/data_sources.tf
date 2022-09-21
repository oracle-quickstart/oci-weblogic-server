# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "time_sleep" "wait_for_wls_vcn_dns_resolver" {
  create_duration = "30s"
}

# When a new VCN is created, the DNS resolver is created asynchronously. Therefore, this data source might return null
# if called right after the VCN is created. That is why we are adding a dependency on the timer. We will wait a certain amount
# of seconds if new WebLogic VCN is used

data "oci_core_vcn_dns_resolver_association" "wls_vcn_resolver_association" {
  count      = var.is_existing_wls_vcn ? 0 : 1
  depends_on = [time_sleep.wait_for_wls_vcn_dns_resolver]
  vcn_id     = var.wls_vcn_id
}

data "oci_core_vcn_dns_resolver_association" "db_vcn_resolver_association" {
  count  = var.is_existing_wls_vcn ? 0 : 1
  vcn_id = var.db_vcn_id
}

data "oci_dns_resolver" "db_vcn_resolver" {
  count       = var.is_existing_wls_vcn ? 0 : 1
  resolver_id = data.oci_core_vcn_dns_resolver_association.db_vcn_resolver_association[0].dns_resolver_id
  scope       = "PRIVATE"
}

data "oci_core_subnet" "db_subnet" {
  subnet_id = var.db_subnet_id
}

data "oci_core_services" "tf_services" {
  filter {
    name   = "cidr_block"
    values = ["all-.*-services-in-oracle-services-network"]
    regex  = true
  }
}
