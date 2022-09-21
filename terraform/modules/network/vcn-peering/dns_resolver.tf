# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

# Add to the DNS resolver of the WebLogic VCN the default view of the DNS resolver of the DB VCN
resource "oci_dns_resolver" "wls_oci_dsn_resolver" {
  count       = var.is_existing_wls_vcn ? 0 : 1
  resolver_id = data.oci_core_vcn_dns_resolver_association.wls_vcn_resolver_association[0].dns_resolver_id
  scope       = "PRIVATE"
  attached_views {
    view_id = data.oci_dns_resolver.db_vcn_resolver[0].default_view_id
  }
  # Prevent Terraform from resetting fields fields like attached_views and rules on reapply,
  # removing changes done manually (e.g add another view)
  lifecycle {
    ignore_changes = all
  }
}