# Copyright (c) 2023, 2024, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_core_network_security_group_security_rule" "bastion_ingress_security_rule" {
  count = var.existing_bastion_instance_id == "" && var.is_bastion_instance_required && !var.assign_backend_public_ip ? 1 : 0

  network_security_group_id = element(var.nsg_ids["bastion_nsg_id"], 0)
  direction                 = "INGRESS"
  protocol                  = "6"


  source      = "0.0.0.0/0"
  source_type = "CIDR_BLOCK"
  stateless   = false

  tcp_options {
    destination_port_range {
      max = 22
      min = 22
    }
  }
}

resource "oci_core_network_security_group_security_rule" "wls_public_ingress_security_rule" {
  count = var.assign_backend_public_ip ? 1 : 0

  network_security_group_id = element(var.nsg_ids["managed_nsg_id"], 0)
  direction                 = "INGRESS"
  protocol                  = "6"


  source      = "0.0.0.0/0"
  source_type = "CIDR_BLOCK"
  stateless   = false

  tcp_options {
    destination_port_range {
      max = 22
      min = 22
    }
  }
}

resource "oci_core_network_security_group_security_rule" "wls_ingress_security_rule" {
  count                     = length(local.wls_admin_port_source_cidrs) > 0 ? length(local.wls_admin_port_source_cidrs) : 0
  network_security_group_id = element(var.nsg_ids["admin_nsg_id"], 0)
  direction                 = "INGRESS"
  protocol                  = "6"


  source      = local.wls_admin_port_source_cidrs[count.index]
  source_type = "CIDR_BLOCK"
  stateless   = false

  tcp_options {
    destination_port_range {
      max = var.wls_extern_ssl_admin_port
      min = var.wls_extern_ssl_admin_port
    }
  }
}

resource "oci_core_network_security_group_security_rule" "wls_ingress_internal_security_rule" {
  count                     = var.configure_secure_mode ? 0 : 1
  network_security_group_id = element(var.nsg_ids["managed_nsg_id"], 0)
  direction                 = "INGRESS"
  protocol                  = "6"

  source      = var.wls_subnet_cidr
  source_type = "CIDR_BLOCK"
  stateless   = false
}

resource "oci_core_network_security_group_security_rule" "wls_ingress_nm_security_rule" {
  network_security_group_id = element(var.nsg_ids["managed_nsg_id"], 0)
  direction                 = "INGRESS"
  protocol                  = "6"

  source      = var.wls_subnet_cidr
  source_type = "CIDR_BLOCK"
  stateless   = false

  tcp_options {
    destination_port_range {
      min = var.wls_nm_port
      max = var.wls_nm_port
    }
  }
}
resource "oci_core_network_security_group_security_rule" "wls_ingress_ssh_security_rule" {
  network_security_group_id = element(var.nsg_ids["managed_nsg_id"], 0)
  direction                 = "INGRESS"
  protocol                  = "6"

  source      = var.wls_subnet_cidr
  source_type = "CIDR_BLOCK"
  stateless   = false

  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
}

resource "oci_core_network_security_group_security_rule" "wls_ingress_administration_port_secure_mode" {
  count                     = var.configure_secure_mode ? 1 : 0
  network_security_group_id = element(var.nsg_ids["managed_nsg_id"], 0)
  direction                 = "INGRESS"
  protocol                  = "6"

  source      = var.wls_subnet_cidr
  source_type = "CIDR_BLOCK"
  stateless   = false

  tcp_options {
    destination_port_range {
      min = var.administration_port
      max = var.administration_port
    }
  }
}

resource "oci_core_network_security_group_security_rule" "wls_ingress_ms_administration_port_secure_mode" {
  count                     = var.configure_secure_mode ? 1 : 0
  network_security_group_id = element(var.nsg_ids["managed_nsg_id"], 0)
  direction                 = "INGRESS"
  protocol                  = "6"

  source      = var.wls_subnet_cidr
  source_type = "CIDR_BLOCK"
  stateless   = false

  tcp_options {
    destination_port_range {
      min = var.ms_administration_port
      max = var.ms_administration_port
    }
  }
}

resource "oci_core_network_security_group_security_rule" "wls_ingress_internal_ssl_security_rule_secure_mode" {
  count                     = var.configure_secure_mode ? 1 : 0
  network_security_group_id = element(var.nsg_ids["managed_nsg_id"], 0)
  direction                 = "INGRESS"
  protocol                  = "6"

  source      = var.wls_subnet_cidr
  source_type = "CIDR_BLOCK"
  stateless   = false

  tcp_options {
    destination_port_range {
      min = var.wls_admin_ssl_port
      max = var.wls_admin_ssl_port
    }
  }
}

resource "oci_core_network_security_group_security_rule" "wls_ingress_app_ms_security_rule" {
  count                     = length(var.wls_ms_source_cidrs) > 0 ? length(var.wls_ms_source_cidrs) : 0
  network_security_group_id = element(var.nsg_ids["managed_nsg_id"], 0)
  direction                 = "INGRESS"
  protocol                  = "6"

  source      = var.wls_ms_source_cidrs[count.index]
  source_type = "CIDR_BLOCK"
  stateless   = false

  tcp_options {
    destination_port_range {
      min = var.wls_ms_content_port
      max = var.wls_ms_content_port
    }
  }
}

resource "oci_core_network_security_group_security_rule" "lb_ingress_security_rule" {
  count                     = var.create_load_balancer ? 1 : 0
  network_security_group_id = element(var.nsg_ids["lb_nsg_id"], 0)
  direction                 = "INGRESS"
  protocol                  = "6"

  source      = var.lb_destination_cidr
  source_type = "CIDR_BLOCK"
  stateless   = false

  tcp_options {
    destination_port_range {
      min = local.port_for_ingress_lb_security_rule
      max = local.port_for_ingress_lb_security_rule
    }
  }
}

resource "oci_core_network_security_group_security_rule" "wls_bastion_ingress_security_rule" {
  count                     = var.existing_bastion_instance_id == "" && var.is_bastion_instance_required && !var.assign_backend_public_ip ? 1 : 0
  network_security_group_id = element(var.nsg_ids["managed_nsg_id"], 0)
  direction                 = "INGRESS"
  protocol                  = "6"

  source      = var.bastion_subnet_cidr
  source_type = "CIDR_BLOCK"
  stateless   = false

  tcp_options {
    destination_port_range {
      max = 22
      min = 22
    }
  }
}

resource "oci_core_network_security_group_security_rule" "wls_existing_bastion_ingress_security_rule" {
  count                     = var.existing_bastion_instance_id != "" && var.is_bastion_instance_required && !var.assign_backend_public_ip ? 1 : 0
  network_security_group_id = element(var.nsg_ids["managed_nsg_id"], 0)
  direction                 = "INGRESS"
  protocol                  = "6"

  source      = format("%s/32", data.oci_core_instance.existing_bastion_instance[count.index].private_ip)
  source_type = "CIDR_BLOCK"
  stateless   = false

  tcp_options {
    destination_port_range {
      max = 22
      min = 22
    }
  }
}

resource "oci_core_network_security_group_security_rule" "wls_admin_bastion_ingress_security_rule" {
  count                     = var.existing_bastion_instance_id == "" && var.is_bastion_instance_required && !var.assign_backend_public_ip ? 1 : 0
  network_security_group_id = element(var.nsg_ids["admin_nsg_id"], 0)
  direction                 = "INGRESS"
  protocol                  = "6"

  source      = var.bastion_subnet_cidr
  source_type = "CIDR_BLOCK"
  stateless   = false

  tcp_options {
    destination_port_range {
      max = local.ssl_admin_port
      min = local.ssl_admin_port
    }
  }
}

resource "oci_core_network_security_group_security_rule" "wls_admin_existing_bastion_ingress_security_rule" {
  count                     = var.existing_bastion_instance_id != "" && var.is_bastion_instance_required && !var.assign_backend_public_ip ? 1 : 0
  network_security_group_id = element(var.nsg_ids["admin_nsg_id"], 0)
  direction                 = "INGRESS"
  protocol                  = "6"

  source      = format("%s/32", data.oci_core_instance.existing_bastion_instance[count.index].private_ip)
  source_type = "CIDR_BLOCK"
  stateless   = false

  tcp_options {
    destination_port_range {
      max = local.ssl_admin_port
      min = local.ssl_admin_port
    }
  }
}

resource "oci_core_network_security_group_security_rule" "fss_ingress_security_rule_1" {
  for_each = {
    for nsg_name, nsg_id in var.nsg_ids :
    nsg_name => nsg_id if nsg_name == "mount_target_nsg_id" && var.add_fss && var.existing_mt_subnet_id == "" && !var.add_existing_mount_target && !var.add_existing_fss
  }
  network_security_group_id = element(each.value, 0)
  direction                 = "INGRESS"
  protocol                  = "6"

  source      = var.vcn_cidr
  source_type = "CIDR_BLOCK"
  stateless   = false

  tcp_options {
    destination_port_range {
      max = 2050
      min = 2048
    }
  }
}

resource "oci_core_network_security_group_security_rule" "fss_ingress_security_rule_2" {
  for_each = {
    for nsg_name, nsg_id in var.nsg_ids :
    nsg_name => nsg_id if nsg_name == "mount_target_nsg_id" && var.add_fss && var.existing_mt_subnet_id == "" && !var.add_existing_mount_target && !var.add_existing_fss
  }
  network_security_group_id = element(each.value, 0)
  direction                 = "INGRESS"
  protocol                  = "6"

  source      = var.vcn_cidr
  source_type = "CIDR_BLOCK"
  stateless   = false

  tcp_options {
    destination_port_range {
      max = 111
      min = 111
    }
  }
}

resource "oci_core_network_security_group_security_rule" "fss_ingress_security_rule_3" {
  for_each = {
    for nsg_name, nsg_id in var.nsg_ids :
    nsg_name => nsg_id if nsg_name == "mount_target_nsg_id" && var.add_fss && var.existing_mt_subnet_id == "" && !var.add_existing_mount_target && !var.add_existing_fss
  }
  network_security_group_id = element(each.value, 0)
  direction                 = "INGRESS"
  protocol                  = "17"

  source      = var.vcn_cidr
  source_type = "CIDR_BLOCK"
  stateless   = false

  udp_options {
    destination_port_range {
      max = 2048
      min = 2048
    }
  }
}

resource "oci_core_network_security_group_security_rule" "fss_ingress_security_rule_4" {
  for_each = {
    for nsg_name, nsg_id in var.nsg_ids :
    nsg_name => nsg_id if nsg_name == "mount_target_nsg_id" && var.add_fss && var.existing_mt_subnet_id == "" && !var.add_existing_mount_target && !var.add_existing_fss
  }
  network_security_group_id = element(each.value, 0)
  direction                 = "INGRESS"
  protocol                  = "17"

  source      = var.wls_subnet_cidr
  source_type = "CIDR_BLOCK"
  stateless   = false

  udp_options {
    destination_port_range {
      max = 111
      min = 111
    }
  }
}

resource "oci_core_network_security_group_security_rule" "egress_security_rule" {
  for_each = {
    for nsg_name, nsg_id in var.nsg_ids :
    nsg_name => nsg_id if nsg_name != "admin_nsg_id" && nsg_name != "mount_target_nsg_id" && length(nsg_id) != 0
  }
  network_security_group_id = element(each.value, 0)
  direction                 = "EGRESS"
  protocol                  = each.key == "lb_nsg_id" ? "6" : "all"

  destination      = "0.0.0.0/0"
  destination_type = "CIDR_BLOCK"
  stateless        = false
}

resource "oci_core_network_security_group_security_rule" "fss_egress_security_rule_1" {
  for_each = {
    for nsg_name, nsg_id in var.nsg_ids :
    nsg_name => nsg_id if nsg_name == "mount_target_nsg_id" && var.add_fss && var.existing_mt_subnet_id == "" && !var.add_existing_mount_target && !var.add_existing_fss
  }
  network_security_group_id = element(each.value, 0)
  direction                 = "EGRESS"
  protocol                  = "6"

  destination      = var.vcn_cidr
  destination_type = "CIDR_BLOCK"
  stateless        = false

  tcp_options {
    source_port_range {
      max = 2050
      min = 2048
    }
  }
}

resource "oci_core_network_security_group_security_rule" "fss_egress_security_rule_2" {
  for_each = {
    for nsg_name, nsg_id in var.nsg_ids :
    nsg_name => nsg_id if nsg_name == "mount_target_nsg_id" && var.add_fss && var.existing_mt_subnet_id == "" && !var.add_existing_mount_target && !var.add_existing_fss
  }
  network_security_group_id = element(each.value, 0)
  direction                 = "EGRESS"
  protocol                  = "6"

  destination      = var.vcn_cidr
  destination_type = "CIDR_BLOCK"
  stateless        = false

  tcp_options {
    source_port_range {
      max = 111
      min = 111
    }
  }
}

resource "oci_core_network_security_group_security_rule" "fss_egress_security_rule_3" {
  for_each = {
    for nsg_name, nsg_id in var.nsg_ids :
    nsg_name => nsg_id if nsg_name == "mount_target_nsg_id" && var.add_fss && var.existing_mt_subnet_id == "" && !var.add_existing_mount_target && !var.add_existing_fss
  }
  network_security_group_id = element(each.value, 0)
  direction                 = "EGRESS"
  protocol                  = "17"

  destination      = var.vcn_cidr
  destination_type = "CIDR_BLOCK"
  stateless        = false

  udp_options {
    source_port_range {
      max = 111
      min = 111
    }
  }
}
