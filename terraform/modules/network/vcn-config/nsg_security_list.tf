# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_core_network_security_group_security_rule" "wls_ssh_ingress_security_list" {

    network_security_group_id = element(var.nsg_ids["admin_nsg_id"],0)
    direction = "INGRESS"
    protocol = "6"


    source =  "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      destination_port_range {
        max = 22
        min = 22
      }
    }
}

resource "oci_core_network_security_group_security_rule" "wls_ingress_security_list" {
    count = length(local.wls_admin_port_source_cidrs) > 0 ? length(local.wls_admin_port_source_cidrs) : 0
    network_security_group_id = element(var.nsg_ids["admin_nsg_id"],0)
    direction = "INGRESS"
    protocol = "6"


    source =  local.wls_admin_port_source_cidrs[count.index]
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      destination_port_range {
        max = var.wls_extern_ssl_admin_port
        min = var.wls_extern_ssl_admin_port
      }
    }
}

resource "oci_core_network_security_group_security_rule" "wls_ingress_internal_security_list" {

  network_security_group_id = element(var.nsg_ids["admin_nsg_id"],0)
  direction = "INGRESS"
  protocol = "6"

  source =  var.wls_subnet_cidr
  source_type = "CIDR_BLOCK"
  stateless   = false
}

resource "oci_core_network_security_group_security_rule" "wls_ingress_lb_ms_security_list" {
  count = length(var.wls_ms_source_cidrs) > 0 ? length(var.wls_ms_source_cidrs) : 0
  network_security_group_id = element(var.nsg_ids["managed_nsg_id"],0)
  direction = "INGRESS"
  protocol = "6"

  source =  var.wls_ms_source_cidrs[count.index]
  source_type = "CIDR_BLOCK"
  stateless   = false

  tcp_options {
    destination_port_range {
       min = var.load_balancer_min_value
       max = var.load_balancer_max_value
    }
  }
}

resource "oci_core_network_security_group_security_rule" "wls_ingress_idcs_ms_security_list" {
  count = length(var.wls_ms_source_cidrs) > 0 ? length(var.wls_ms_source_cidrs) : 0
  network_security_group_id = element(var.nsg_ids["managed_nsg_id"],0)
  direction = "INGRESS"
  protocol = "6"

  source =  var.wls_ms_source_cidrs[count.index]
  source_type = "CIDR_BLOCK"
  stateless   = false

  tcp_options {
    destination_port_range {
       min = var.wls_ms_content_port
       max = var.wls_ms_content_port
    }
  }
}

resource "oci_core_network_security_group_security_rule" "lb_ingress_security_list" {
  count = var.create_lb_sec_list ? 1 : 0
  network_security_group_id = element(var.nsg_ids["lb_nsg_id"],0)
  direction = "INGRESS"
  protocol = "6"

  source =  var.lb_destination_cidr
  source_type = "CIDR_BLOCK"
  stateless   = false

  tcp_options {
    destination_port_range {
       min = local.port_for_ingress_lb_security_list
       max = local.port_for_ingress_lb_security_list
    }
  }
}

resource "oci_core_network_security_group_security_rule" "bastion_ingress_security_list" {
  count          = var.existing_bastion_instance_id == "" && var.is_bastion_instance_required ? 1 : 0
  network_security_group_id = element(var.nsg_ids["bastion_nsg_id"],0)
  direction = "INGRESS"      
  protocol = "all"

  source =  var.bastion_subnet_cidr
  source_type = "CIDR_BLOCK"
  stateless   = false
}

resource "oci_core_network_security_group_security_rule" "existing_bastion_ingress_security_list" {
  count          = var.existing_bastion_instance_id != "" && var.is_bastion_instance_required ? 1 : 0
  network_security_group_id = element(var.nsg_ids["bastion_nsg_id"],0)
  direction = "INGRESS"
  protocol = "all"
  
  source =  format("%s/32", data.oci_core_instance.existing_bastion_instance[count.index].private_ip)
  source_type = "CIDR_BLOCK"
  stateless   = false
}

resource "oci_core_network_security_group_security_rule" "egress_security_list" {
  for_each = {
    for nsg_name, nsg_id in var.nsg_ids :
    nsg_name => nsg_id if nsg_name != "managed_nsg_id"
  }
  network_security_group_id = element(each.value,0)
  direction = "EGRESS"
  protocol = each.key == "lb_nsg_id" ? "6" : "all"

  destination =  "0.0.0.0/0"
  destination_type = "CIDR_BLOCK"
  stateless   = false
}
