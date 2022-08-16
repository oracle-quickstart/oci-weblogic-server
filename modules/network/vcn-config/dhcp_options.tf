/*
 * Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
 */

/*
* Creates a new dhcp options for the specified VCN.
* Note:
*   Only when either of wls_vcn_name is passed or existing_vcn_id is passed then create new DHCP option
*   otherwise if both are passed it is vcn
* Also see:
*   https://www.terraform.io/docs/providers/oci/r/core_dhcp_options.html,
*   https://www.terraform.io/docs/providers/oci/guides/managing_default_resources.html
*/

resource "oci_core_dhcp_options" "wls-dhcp-options1" {
  count          = var.is_vcn_peering || var.appdb_vcn_peering ? 0 : (var.use_existing_subnets?0:1)
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "${var.service_name_prefix}-${var.dhcp_options_name}"

  // required
  options {
    type        = "DomainNameServer"
    server_type = "VcnLocalPlusInternet"
  }

  defined_tags = var.defined_tags
  freeform_tags = var.freeform_tags
}
