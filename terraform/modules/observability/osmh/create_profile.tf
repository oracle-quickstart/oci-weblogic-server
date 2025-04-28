resource "oci_os_management_hub_software_source_change_availability_management" "software_source_change_availability_management" {
   for_each = toset(local.filtered_sources)  

  software_source_availabilities {
    software_source_id  = each.value  
    availability_at_oci = var.software_availabilty
  }
}

resource "oci_os_management_hub_profile" "create_profile" {
    compartment_id      = var.compartment_id
    display_name        = var.display_name
    profile_type        = var.profile_type
    software_source_ids = local.filtered_sources
    arch_type           = var.arch_type
    is_default_profile  = var.is_default_profile
    os_family           = var.os_family
    registration_type   = var.registration_type
    vendor_name         = var.vendor_name
    depends_on = [
    oci_os_management_hub_software_source_change_availability_management.software_source_change_availability_management
  ]
}
