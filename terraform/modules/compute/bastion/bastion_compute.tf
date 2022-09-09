# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

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
    nsg_ids                = var.bastion_nsg_id
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
