# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.


#Get Image Agreement
resource "oci_core_app_catalog_listing_resource_version_agreement" "wls_mp_image_agreement" {
  count                    = var.use_marketplace_image ? 1 : 0
  listing_id               = var.mp_listing_id
  listing_resource_version = var.mp_listing_resource_version
}

#Accept Terms and Subscribe to the image, placing the image in a particular compartment
resource "oci_core_app_catalog_subscription" "wls_mp_image_subscription" {
  count                    = var.use_marketplace_image ? 1 : 0
  compartment_id           = var.compartment_id
  eula_link                = oci_core_app_catalog_listing_resource_version_agreement.wls_mp_image_agreement[0].eula_link
  listing_id               = oci_core_app_catalog_listing_resource_version_agreement.wls_mp_image_agreement[0].listing_id
  listing_resource_version = oci_core_app_catalog_listing_resource_version_agreement.wls_mp_image_agreement[0].listing_resource_version
  oracle_terms_of_use_link = oci_core_app_catalog_listing_resource_version_agreement.wls_mp_image_agreement[0].oracle_terms_of_use_link
  signature                = oci_core_app_catalog_listing_resource_version_agreement.wls_mp_image_agreement[0].signature
  time_retrieved           = oci_core_app_catalog_listing_resource_version_agreement.wls_mp_image_agreement[0].time_retrieved

  timeouts {
    create = "20m"
  }
}

resource "oci_core_app_catalog_listing_resource_version_agreement" "wls_mp_ucm_image_agreement" {
  count                    = var.use_marketplace_image && var.is_ucm_image ? 1 : 0
  listing_id               = var.mp_ucm_listing_id
  listing_resource_version = var.mp_ucm_listing_resource_version
}

#Accept Terms and Subscribe to the image, placing the image in a particular compartment
resource "oci_core_app_catalog_subscription" "wls_mp_ucm_image_subscription" {
  count                    = var.use_marketplace_image && var.is_ucm_image ? 1 : 0
  compartment_id           = var.compartment_id
  eula_link                = oci_core_app_catalog_listing_resource_version_agreement.wls_mp_ucm_image_agreement[0].eula_link
  listing_id               = oci_core_app_catalog_listing_resource_version_agreement.wls_mp_ucm_image_agreement[0].listing_id
  listing_resource_version = oci_core_app_catalog_listing_resource_version_agreement.wls_mp_ucm_image_agreement[0].listing_resource_version
  oracle_terms_of_use_link = oci_core_app_catalog_listing_resource_version_agreement.wls_mp_ucm_image_agreement[0].oracle_terms_of_use_link
  signature                = oci_core_app_catalog_listing_resource_version_agreement.wls_mp_ucm_image_agreement[0].signature
  time_retrieved           = oci_core_app_catalog_listing_resource_version_agreement.wls_mp_ucm_image_agreement[0].time_retrieved

  timeouts {
    create = "20m"
  }
}
