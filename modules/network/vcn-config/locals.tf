# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  port_for_ingress_lb_security_list = 443
  lb_destination_cidr               = var.is_lb_private ? var.bastion_subnet_cidr : "0.0.0.0/0"
  wls_ms_source_cidrs         = var.wls_ms_source_cidrs
  wls_admin_port_source_cidrs = var.wls_expose_admin_port ? [var.wls_admin_port_source_cidr] : []
}
