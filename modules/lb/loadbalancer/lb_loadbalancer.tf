
locals {
  reserved_ips_info = var.add_lb_reserved_public_ip_id ? [ var.lb_reserved_public_ip_id ] : []
}

resource "oci_load_balancer_load_balancer" "wls_loadbalancer" {
  count = var.add_load_balancer && var.existing_load_balancer_id == "" ? 1 : 0

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
  display_name  = var.lb_name
  is_private    = var.is_lb_private
  defined_tags  = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags

  dynamic "reserved_ips" {
    for_each = local.reserved_ips_info
    content {
      id = reserved_ips.value
    }
  }

}
