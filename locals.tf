locals {

  dg_system_tags_key =  format("%s.%s", module.system-tags.tag_namespace, module.system-tags.dg_tag_key)
  dynamic_group_rule = local.create_dg_tags ? format("%s.%s.%s='%s'", "tag", local.dg_system_tags_key, "value", module.system-tags.dg_tag_value) : length(var.service_tags.definedTags) > 0 ? format("tag.%s.value='%s'", keys(var.service_tags.definedTags)[0],values(var.service_tags.definedTags)[0]): ""
  dg_defined_tags    = zipmap([local.dg_system_tags_key], [module.system-tags.dg_tag_value])
  defined_tags = var.service_tags.definedTags
  free_form_tags = length(var.service_tags.freeformTags) >0 ? var.service_tags.freeformTags : module.system-tags.system_tag_value

  create_dg_tags = var.create_policies && var.generate_dg_tag

  home_region      = lookup(data.oci_identity_regions.home_region.regions[0], "name")

  service_name_prefix = replace(var.service_name, "/[^a-zA-Z0-9]/", "")

  bastion_availability_domain = var.bastion_subnet_id != "" ? (var.use_regional_subnet ? var.wls_availability_domain_name !="" ? var.wls_availability_domain_name : local.ad_names[0] : data.oci_core_subnet.bastion_subnet[0].availability_domain) : (var.use_regional_subnet ? var.wls_availability_domain_name !="" ? var.wls_availability_domain_name : local.ad_names[0] : var.wls_availability_domain_name)

  wls_availability_domain      = var.use_regional_subnet ? (var.wls_availability_domain_name == "" ? local.ad_names[0] : var.wls_availability_domain_name) : (var.wls_subnet_id == "" ? var.wls_availability_domain_name : data.oci_core_subnet.wls_subnet[0].availability_domain)

  network_compartment_id = var.network_compartment_id == "" ? var.compartment_id : var.network_compartment_id

  ad_names                    = compact(data.template_file.ad_names.*.rendered)
}