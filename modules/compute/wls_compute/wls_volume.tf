module "middleware-volume" {
  source = "../volume"
  bv_params = {for x in range(var.numVMInstances) : "${var.compute_name_prefix}-mw-block-${x}" => {
      ad                   = var.use_regional_subnet?local.ad_names[x % length(local.ad_names)]:var.availability_domain
      compartment_id       = var.compartment_ocid
      display_name         = "${var.compute_name_prefix}-mw-block-${x}"
      bv_size              = var.volume_size
      defined_tags         = var.defined_tags
      freeform_tags        = var.freeform_tags
    }
  }

  bv_attach_params = {empty={display_name="", attachment_type="", instance_id="", volume_id="" }}
}

module "data-volume" {
  source = "../volume"
  bv_params = {for x in range(var.numVMInstances) : "${var.compute_name_prefix}-data-block-${x}" => {
      ad                   = var.use_regional_subnet?local.ad_names[x % length(local.ad_names)]:var.availability_domain
      compartment_id       = var.compartment_ocid
      display_name         = "${var.compute_name_prefix}-data-block-${x}"
      bv_size              = var.volume_size
      defined_tags         = var.defined_tags
      freeform_tags        = var.freeform_tags
    } 
  }
  bv_attach_params = {empty={display_name="", attachment_type="", instance_id="", volume_id=""}}
}

module "middleware_volume_attach" {
  source = "../volume"

  bv_params = {empty={ad = "", compartment_id = "", display_name = "", bv_size  = 0, defined_tags = {def=""}, freeform_tags = {free=""}}}

  bv_attach_params = {for x in range(var.numVMInstances * var.num_volumes) : "${var.compute_name_prefix}-block-volume-attach-${x}" => {
    display_name    = "${var.compute_name_prefix}-block-volume-attach-${x}"
    attachment_type = "iscsi"
    instance_id     = module.wls-instances.InstanceOcids[x / var.num_volumes]
    volume_id       = module.middleware-volume.DataVolumeOcids[x / var.num_volumes]
  }
  }
}

module "data_volume_attach" {
  source = "../volume"

  bv_params = {empty={ad = "", compartment_id = "", display_name = "", bv_size  = 0, defined_tags = {def=""}, freeform_tags = {free=""}}}

  bv_attach_params = {for x in range(var.numVMInstances * var.num_volumes) : "${var.compute_name_prefix}-block-volume-attach-${x}" => {
    display_name    = "${var.compute_name_prefix}-block-volume-attach-${x}"
    attachment_type = "iscsi"
    instance_id     = module.wls-instances.InstanceOcids[x / var.num_volumes]
    volume_id       = module.data-volume.DataVolumeOcids[x / var.num_volumes]
  }
  }
}
