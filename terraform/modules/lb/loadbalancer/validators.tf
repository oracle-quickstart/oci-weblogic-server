# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {

  validators_msg_map = {
    #Dummy map to trigger an error in case we detect a validation error.
  }

  add_lb_reserved_public_ip_id           = length(var.lb_reserved_public_ip_id) == 1 ? true : false
  invalid_lb_bandwidth                   = (var.lb_max_bandwidth > 8000) || (var.lb_min_bandwidth < 10) || (var.lb_max_bandwidth < var.lb_min_bandwidth)
  invalid_add_lb_reserved_public_ip_ocid = var.is_lb_private && local.add_lb_reserved_public_ip_id

  lb_bandwidth_msg      = "WLSC-ERROR: Please provide valid lb_max_bandwidth and lb_min_bandwidth values based on lb flexible quota limit in the tenancy"
  validate_lb_bandwidth = local.invalid_lb_bandwidth ? local.validators_msg_map[local.lb_bandwidth_msg] : ""

  add_lb_reserved_public_ip_ocid_msg      = "WLSC-ERROR: Provisioning load balancer with reserved public IP is supported only for public load balancer."
  validate_add_lb_reserved_public_ip_ocid = local.invalid_add_lb_reserved_public_ip_ocid ? local.validators_msg_map[local.add_lb_reserved_public_ip_ocid_msg] : null

}