# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  port_for_ingress_lb_security_list = 443
  wls_admin_port_source_cidrs = var.wls_expose_admin_port ? [var.wls_admin_port_source_cidr] : []
  num_nat_gws = length(var.nat_gateway_ids)
  nat_gw_exists = local.num_nat_gws == 0 ? false : true
}

