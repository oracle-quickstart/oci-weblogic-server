# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  service_name_prefix = replace(var.service_name, "/[^a-zA-Z0-9]/", "")

  home_region = lookup(data.oci_identity_regions.home_region.regions[0], "name")
  ad_names    = compact(data.template_file.ad_names.*.rendered)

  bastion_availability_domain = var.bastion_subnet_id != "" ? (var.use_regional_subnet ? var.wls_availability_domain_name != "" ? var.wls_availability_domain_name : local.ad_names[0] : data.oci_core_subnet.bastion_subnet[0].availability_domain) : (var.use_regional_subnet ? var.wls_availability_domain_name != "" ? var.wls_availability_domain_name : local.ad_names[0] : var.wls_availability_domain_name)
  wls_availability_domain     = var.use_regional_subnet ? (var.wls_availability_domain_name == "" ? local.ad_names[0] : var.wls_availability_domain_name) : (var.wls_subnet_id == "" ? var.wls_availability_domain_name : data.oci_core_subnet.wls_subnet[0].availability_domain)
  network_compartment_id      = var.network_compartment_id == "" ? var.compartment_id : var.network_compartment_id
  assign_weblogic_public_ip = var.assign_weblogic_public_ip || var.subnet_type == "Use Public Subnet" ? true : false

  #dynamic group is based on the system generated tags for DG
  create_dg_tags     = var.create_policies && var.generate_dg_tag # Only create dynamic group tags when create policies and generate dg tag is true
  dg_system_tags_key = local.create_dg_tags ? format("%s.%s", module.system-tags.tag_namespace, module.system-tags.dg_tag_key) : ""
  dynamic_group_rule = local.create_dg_tags ? format("%s.%s.%s='%s'", "tag", local.dg_system_tags_key, "value", module.system-tags.dg_tag_value) : length(var.service_tags.definedTags) > 0 ? format("tag.%s.value='%s'", keys(var.service_tags.definedTags)[0], values(var.service_tags.definedTags)[0]) : ""
  dg_defined_tags    = local.create_dg_tags ? zipmap([local.dg_system_tags_key], [module.system-tags.dg_tag_value]) : {}
  defined_tags       = var.service_tags.definedTags
  free_form_tags     = length(var.service_tags.freeformTags) > 0 ? var.service_tags.freeformTags : module.system-tags.system_tag_value

  user_defined_tag_values = values(var.service_tags.definedTags)


  use_existing_subnets = var.wls_subnet_id == "" && var.lb_subnet_1_id == "" && var.lb_subnet_2_id == "" ? false : true
  #use_existing_subnets = false
  is_vcn_peering        = false
  bastion_subnet_cidr      = var.bastion_subnet_cidr == "" && var.wls_vcn_name != "" && ! local.assign_weblogic_public_ip ? local.is_vcn_peering ? "11.0.1.0/24" : "10.0.1.0/24" : var.bastion_subnet_cidr
  wls_subnet_cidr          = var.wls_subnet_cidr == "" && var.wls_vcn_name != "" ? local.is_vcn_peering ? "11.0.2.0/24" : "10.0.2.0/24" : var.wls_subnet_cidr
  lb_subnet_1_subnet_cidr  = var.lb_subnet_1_cidr == "" && var.wls_vcn_name != "" ? local.is_vcn_peering ? "11.0.3.0/24" : "10.0.3.0/24" : var.lb_subnet_1_cidr
  lb_subnet_2_subnet_cidr  = var.lb_subnet_2_cidr == "" && var.wls_vcn_name != "" ? local.is_vcn_peering ? "11.0.4.0/24" : "10.0.4.0/24" : var.lb_subnet_2_cidr
  num_ads = length(
    data.oci_identity_availability_domains.ADs.availability_domains,
  )
  is_single_ad_region = local.num_ads == 1 ? true : false
  use_regional_subnet    = (var.use_regional_subnet && var.subnet_span == "Regional Subnet")
  vcn_id = var.wls_existing_vcn_id=="" ? module.network-vcn[0].vcn_id : var.wls_existing_vcn_id

}
