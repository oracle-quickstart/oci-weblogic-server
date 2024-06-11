# Copyright (c) 2023, 2024, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

module "middleware-volume" {
  source = "../volume"
  bv_params = { for x in range(var.num_vm_instances) : "${var.resource_name_prefix}-mw-block-${format("%02d", x)}" => {
    ad             = var.use_regional_subnet ? local.ad_names[(x + local.admin_ad_index) % length(local.ad_names)] : var.availability_domain
    compartment_id = var.compartment_id
    display_name   = "${var.resource_name_prefix}-mw-block-${x}"
    bv_size        = var.volume_size
    defined_tags   = var.tags.defined_tags
    freeform_tags  = var.tags.freeform_tags
    }
  }

  bv_attach_params = { empty = { display_name = "", attachment_type = "", instance_id = "", volume_id = "" } }
}

module "data-volume" {
  source = "../volume"
  bv_params = { for x in range(var.num_vm_instances) : "${var.resource_name_prefix}-data-block-${format("%02d", x)}" => {
    ad             = var.use_regional_subnet ? local.ad_names[(x + local.admin_ad_index) % length(local.ad_names)] : var.availability_domain
    compartment_id = var.compartment_id
    display_name   = "${var.resource_name_prefix}-data-block-${x}"
    bv_size        = var.volume_size
    defined_tags   = var.tags.defined_tags
    freeform_tags  = var.tags.freeform_tags
    }
  }
  bv_attach_params = { empty = { display_name = "", attachment_type = "", instance_id = "", volume_id = "" } }
}

module "middleware_volume_attach" {
  source = "../volume"

  bv_params = { empty = { ad = "", compartment_id = "", display_name = "", bv_size = 0, defined_tags = { def = "" }, freeform_tags = { free = "" } } }

  bv_attach_params = { for x in range(var.num_vm_instances * var.num_volumes) : "${var.resource_name_prefix}-block-volume-attach-${format("%02d", x)}" => {
    display_name    = "${var.resource_name_prefix}-block-volume-attach-${x}"
    attachment_type = "iscsi"
    instance_id     = module.wls-instances.instance_ids[x / var.num_volumes]
    volume_id       = module.middleware-volume.data_volume_ids[x / var.num_volumes]
    }
  }
}

module "data_volume_attach" {
  source = "../volume"

  bv_params = { empty = { ad = "", compartment_id = "", display_name = "", bv_size = 0, defined_tags = { def = "" }, freeform_tags = { free = "" } } }

  bv_attach_params = { for x in range(var.num_vm_instances * var.num_volumes) : "${var.resource_name_prefix}-block-volume-attach-${format("%02d", x)}" => {
    display_name    = "${var.resource_name_prefix}-block-volume-attach-${x}"
    attachment_type = "iscsi"
    instance_id     = module.wls-instances.instance_ids[x / var.num_volumes]
    volume_id       = module.data-volume.data_volume_ids[x / var.num_volumes]
    }
  }
}
