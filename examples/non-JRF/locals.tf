locals {

  dg_system_tags_key =  format("%s.%s", module.system-tags.tag_namespace, module.system-tags.dg_tag_key)
  dynamic_group_rule = format("%s.%s.%s='%s'", "tag", local.dg_system_tags_key, "value", module.system-tags.dg_tag_value)
  dg_defined_tags    = zipmap([local.dg_system_tags_key], [module.system-tags.dg_tag_value])

}