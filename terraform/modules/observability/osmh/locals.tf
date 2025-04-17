locals {
  all_sources = data.oci_os_management_hub_software_sources.all_sources.software_source_collection[0].items
  software_source_names = [
    "ol8_addons-x86_64",
    "ol8_appstream-x86_64",
    "ol8_baseos_latest-x86_64",
    "ol8_ksplice-x86_64",
    "ol8_mysql80_connectors_community-x86_64",
    "ol8_mysql80_tools_community-x86_64",
    "ol8_oci_included-x86_64",
    "ol8_uekr7-x86_64",
    "ol8_mysql80_community-x86_64"
  ]

  filtered_sources = [
    for src in local.all_sources : src.id
    if contains(local.software_source_names, src.display_name)
  ]
}