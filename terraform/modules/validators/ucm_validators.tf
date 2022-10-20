# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {

  ucm_instance_count_new = var.ucm_instance_count + 1
  use_byol_image = (var.image_mode == "Oracle WebLogic Server BYOL Image")

  # instance image id and mp_ucm_image_id is different for BYOL bundles but same for UCM bundles
  validate_image_mode = (var.wls_edition != "SE" && var.use_marketplace_image && var.instance_image_id != var.ucm_instance_image_id)

  image_mode_msg   = "WLSC-ERROR: Select Terms and Conditions only if UCM images are used for BYOL stack"
  validate_terms_and_conditions   = local.validate_image_mode && (!local.use_byol_image && !var.terms_and_conditions) ? local.validators_msg_map[local.image_mode_msg] : ""

  #Validate if the UCM or the BYOL nodes needs to be added based on terms_and_conditions field
  ucm_node_count = (var.ucm_instance_count > 0)

  mix_ucm_byol_nodes = "WLSC-ERROR: You are attempting to add BYOL nodes to an instance that has UCM nodes. In order to add BYOL nodes you must first reduce the node count by ${local.ucm_instance_count_new}  so that your instance only contains BYOL nodes. Then, reset the node count to the desired number."
  validate_mix_ucm_byol_nodes = local.validate_image_mode && var.use_marketplace_image && !var.terms_and_conditions && local.ucm_node_count && (var.provisioned_node_count < var.num_vm_instances) ? local.validators_msg_map[local.mix_ucm_byol_nodes] : null

}
