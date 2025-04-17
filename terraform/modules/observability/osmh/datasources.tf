data "oci_identity_tenancy" "test_tenancy" {
    tenancy_id = var.tenancy_id
}
data "oci_os_management_hub_software_sources" "all_sources" {
  compartment_id = data.oci_identity_tenancy.test_tenancy.id
}





