# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.


#Get Image Agreement
resource "oci_core_app_catalog_listing_resource_version_agreement" "mp_image_agreement" {
  count  = var.use_bastion_marketplace_image ? 1 : 0
  listing_id               = var.mp_listing_id
  listing_resource_version = var.mp_listing_resource_version
}

#Accept Terms and Subscribe to the image, placing the image in a particular compartment
resource "oci_core_app_catalog_subscription" "mp_image_subscription" {
  count  = var.use_bastion_marketplace_image ? 1 : 0
  compartment_id           = var.compartment_id
  eula_link                = oci_core_app_catalog_listing_resource_version_agreement.mp_image_agreement[0].eula_link
  listing_id               = oci_core_app_catalog_listing_resource_version_agreement.mp_image_agreement[0].listing_id
  listing_resource_version = oci_core_app_catalog_listing_resource_version_agreement.mp_image_agreement[0].listing_resource_version
  oracle_terms_of_use_link = oci_core_app_catalog_listing_resource_version_agreement.mp_image_agreement[0].oracle_terms_of_use_link
  signature                = oci_core_app_catalog_listing_resource_version_agreement.mp_image_agreement[0].signature
  time_retrieved           = oci_core_app_catalog_listing_resource_version_agreement.mp_image_agreement[0].time_retrieved

  timeouts {
    create = "20m"
  }
}

resource "oci_core_instance" "wls-bastion-instance" {

  availability_domain = var.availability_domain

  compartment_id = var.compartment_id
  display_name   = var.instance_name
  shape          = var.instance_shape

  defined_tags  = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags

  create_vnic_details {
    subnet_id              = var.bastion_subnet_id
    assign_public_ip       = var.is_bastion_with_reserved_public_ip ? false : true
    skip_source_dest_check = true
  }

  shape_config {
    ocpus = local.ocpus
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = data.template_cloudinit_config.bastion-config.rendered
  }

  instance_options {
    are_legacy_imds_endpoints_disabled = var.disable_legacy_metadata_endpoint
  }
  source_details {
    source_type = "image"
    source_id   = var.instance_image_id
  }

  timeouts {
    create = "10m"
  }

   lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

resource "oci_core_public_ip" "reserved_public_ip" {
  count = var.is_bastion_with_reserved_public_ip ? 1 : 0

  compartment_id = var.compartment_id
  display_name   = "${var.instance_name}-reserved-public-ip"
  lifetime       = "RESERVED"
  private_ip_id  = data.oci_core_private_ips.bastion_private_ips[0].private_ips[0]["id"]

  defined_tags  = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags

   lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}
