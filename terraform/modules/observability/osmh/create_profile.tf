resource "oci_os_management_hub_software_source_change_availability_management" "test_software_source_change_availability_management" {
   for_each = toset(local.filtered_sources)  

  software_source_availabilities {
    # Required
    software_source_id = each.value  
    availability_at_oci = var.software_source_change_availability_management_software_source_availabilities_availability_at_oci
  }

}

resource "oci_os_management_hub_profile" "create_profile" {
    compartment_id = var.compartment_id
    display_name = var.display_name
    profile_type = "SOFTWARESOURCE"
    software_source_ids = local.filtered_sources
    arch_type = var.arch_type
    is_default_profile = var.is_default_profile
    os_family = var.os_family
    registration_type = var.registration_type
    vendor_name = var.vendor_name
}
