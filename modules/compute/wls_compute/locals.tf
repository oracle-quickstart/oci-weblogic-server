# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  host_label     = "${var.resource_name_prefix}-${var.vnic_prefix}"
  ad_names       = compact(data.template_file.ad_names.*.rendered)
  admin_ad_index = index(local.ad_names, var.availability_domain == "" ? local.ad_names[0] : var.availability_domain)

  num_fault_domains = length(data.oci_identity_fault_domains.wls_fault_domains.fault_domains)

  #add both resource tags and tags for dg
  defined_tags = merge(var.tags.defined_tags, var.tags.dg_defined_tags)

  opc_key    = module.compute-keygen.opc_keys
  oracle_key = module.compute-keygen.oracle_keys

  is_atp_db = trimspace(var.jrf_parameters.atp_db_parameters.atp_db_id) != ""
  apply_JRF = local.is_atp_db

  wls_subnet_cidr    = (var.wls_subnet_id == "") ? var.wls_subnet_cidr : data.oci_core_subnet.wls_subnet[0].cidr_block
}