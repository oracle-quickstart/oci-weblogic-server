data "oci_identity_tenancy" "tenancy_ocid" {
    tenancy_id = var.tenancy_id
}
data "oci_os_management_hub_software_sources" "all_tenancy_osmh_software_sources" {
  compartment_id = data.oci_identity_tenancy.tenancy_ocid.id
}





