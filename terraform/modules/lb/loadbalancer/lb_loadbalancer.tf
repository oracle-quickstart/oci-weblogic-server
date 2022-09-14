# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_load_balancer_load_balancer" "wls_loadbalancer" {

  shape          = var.lb_shape
  compartment_id = var.compartment_id

  subnet_ids = compact(
    concat(
      compact(var.lb_subnet_1_id),
      compact(var.lb_subnet_2_id)
    )
  )

  shape_details {
    #Required
    maximum_bandwidth_in_mbps = var.lb_max_bandwidth
    minimum_bandwidth_in_mbps = var.lb_min_bandwidth
  }
  display_name               = var.lb_name
  is_private                 = var.is_lb_private
  network_security_group_ids = var.lb_nsg_id
  defined_tags               = var.tags.defined_tags
  freeform_tags              = var.tags.freeform_tags

  dynamic "reserved_ips" {
    for_each = var.lb_reserved_public_ip_id
    content {
      id = reserved_ips.value
    }
  }

  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}
