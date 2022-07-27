locals {
  host_label     = "${var.resource_name_prefix}-${var.vnic_prefix}"
  ad_names       = compact(data.template_file.ad_names.*.rendered)
  admin_ad_index = index(local.ad_names, var.availability_domain == "" ? local.ad_names[0] : var.availability_domain)

  num_fault_domains = length(data.oci_identity_fault_domains.wls_fault_domains.fault_domains)

  #add both resource tags and tags for dg
  defined_tags = merge(var.tags.defined_tags, var.tags.dg_defined_tags)

  opc_key    = module.compute-keygen.opc_keys
  oracle_key = module.compute-keygen.oracle_keys
}