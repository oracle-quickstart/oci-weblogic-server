# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_core_instance" "these" {

  for_each = var.instance_params

  availability_domain = each.value.availability_domain
  compartment_id      = each.value.compartment_id
  display_name        = each.value.display_name
  shape               = each.value.shape.instanceShape

  defined_tags  = each.value.defined_tags
  freeform_tags = each.value.freeform_tags

  create_vnic_details {
    subnet_id        = each.value.subnet_id
    display_name     = each.value.vnic_display_name
    assign_public_ip = each.value.assign_public_ip
    hostname_label   = each.value.hostname_label
    nsg_ids          = each.value.compute_nsg_ids
  }

  dynamic "shape_config" {
    for_each = length(regexall("^.*Flex", each.value.shape.instanceShape)) > 0 ? [1] : []
    content {
      ocpus = each.value.shape.ocpus
      # TODO: uncomment this when UI uses control with flex shape
      #memory_in_gbs = each.value.shape.memory
    }
  }

  source_details {
    source_type = each.value.source_type
    source_id   = each.value.source_id
  }

  agent_config {
    are_all_plugins_disabled = false
    is_management_disabled   = false
    is_monitoring_disabled   = false
    plugins_config {
      #Required
      desired_state = "ENABLED"
      name          = "Bastion"
    }
  }

  metadata = each.value.metadata

  instance_options {
    are_legacy_imds_endpoints_disabled = each.value.are_legacy_imds_endpoints_disabled
  }

  fault_domain = each.value.fault_domain

  timeouts {
    create = "${each.value.provisioning_timeout_mins}m"
  }

  lifecycle {
    ignore_changes = [metadata, shape, shape_config, source_details, defined_tags, freeform_tags]
  }
}
