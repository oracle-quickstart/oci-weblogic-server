# Copyright (c) 2023, 2024, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  port_for_ingress_lb_security_rule = 443
  wls_admin_port_source_cidrs       = var.wls_expose_admin_port ? [var.wls_admin_port_source_cidr] : []
  nat_gw_exists                     = length(var.existing_nat_gateway_ids) == 0 ? false : true
  # TODO: replace 9002 with administration port variable : JCS-14313
  ssl_admin_port                    = var.configure_secure_mode ? 9002 : var.wls_extern_ssl_admin_port
}
