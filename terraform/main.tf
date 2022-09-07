# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

module "system-tags" {
  source         = "./modules/resource-tags"
  compartment_id = var.compartment_id
  service_name   = var.service_name
  is_system_tag  = true # TODO: should we allow to customize this?
  create_dg_tags = local.create_dg_tags
  providers = {
    oci = oci.home
  }
}

module "network-vcn" {
  source               = "./modules/network/vcn"
  count                = var.wls_existing_vcn_id != "" ? 0 : 1
  compartment_id       = local.network_compartment_id
  vcn_name             = var.wls_vcn_name
  wls_vcn_cidr         = var.wls_vcn_cidr
  resource_name_prefix = local.service_name_prefix
  tags = {
    defined_tags  = local.defined_tags
    freeform_tags = local.free_form_tags
  }
}

module "network-vcn-config" {
  source         = "./modules/network/vcn-config"
  count          = local.use_existing_subnets ? 0 : 1
  compartment_id = local.network_compartment_id

  //vcn id if new is created
  vcn_id = local.vcn_id

  wls_extern_ssl_admin_port  = var.wls_extern_ssl_admin_port
  wls_extern_admin_port      = var.wls_extern_admin_port
  wls_expose_admin_port      = var.wls_expose_admin_port
  wls_admin_port_source_cidr = var.wls_admin_port_source_cidr
  wls_ms_content_port        = var.is_idcs_selected ? var.idcs_cloudgate_port : var.wls_ms_extern_ssl_port

  wls_security_list_name       = !var.assign_weblogic_public_ip ? "bastion-security-list" : "wls-security-list"
  wls_subnet_cidr              = local.wls_subnet_cidr
  wls_ms_source_cidrs          = var.add_load_balancer ? ((local.use_regional_subnet || local.is_single_ad_region) ? [local.lb_subnet_2_subnet_cidr] : [local.lb_subnet_1_subnet_cidr, local.lb_subnet_2_subnet_cidr]) : ["0.0.0.0/0"]
  load_balancer_min_value      = var.add_load_balancer ? var.wls_ms_extern_port : var.wls_ms_extern_ssl_port
  load_balancer_max_value      = var.add_load_balancer ? var.wls_ms_extern_port : var.wls_ms_extern_ssl_port
  create_lb_sec_list           = var.add_load_balancer
  resource_name_prefix         = local.service_name_prefix
  bastion_subnet_cidr          = local.bastion_subnet_cidr
  is_bastion_instance_required = var.is_bastion_instance_required
  existing_bastion_instance_id = var.existing_bastion_instance_id
  vcn_cidr                     = element(concat(module.network-vcn.*.vcn_cidr, tolist([""])), 0)
  existing_mt_subnet_id        = var.mount_target_subnet_id
  existing_service_gateway_ids = var.wls_vcn_name == "" ? [] : data.oci_core_service_gateways.service_gateways.service_gateways.*.id
  existing_nat_gateway_ids     = var.wls_vcn_name == "" ? [] : data.oci_core_nat_gateways.nat_gateways.nat_gateways.*.id
  create_nat_gateway           = var.is_idcs_selected && length(data.oci_core_nat_gateways.nat_gateways.*.id) == 0
  create_service_gateway       = length(data.oci_core_nat_gateways.nat_gateways.*.id) > 0
  lb_destination_cidr          = var.is_lb_private ? var.bastion_subnet_cidr : "0.0.0.0/0"
  add_fss                      = var.add_fss

  tags = {
    defined_tags  = local.defined_tags
    freeform_tags = local.free_form_tags
  }
}


/* Create primary subnet for Load balancer only */
module "network-lb-subnet-1" {
  source            = "./modules/network/subnet"
  count             = local.add_existing_load_balancer ? 0 : var.add_load_balancer && var.lb_subnet_1_id == "" ? 1 : 0
  compartment_id    = local.network_compartment_id
  vcn_id            = local.vcn_id
  security_list_ids = module.network-vcn-config[0].lb_security_list_id
  dhcp_options_id   = module.network-vcn-config[0].dhcp_options_id
  route_table_id    = module.network-vcn-config[0].route_table_id

  subnet_name = "${local.service_name_prefix}-${local.lb_subnet_1_name}"
  #Note: limit for dns label is 15 chars
  dns_label  = format("%s-%s", local.lb_subnet_1_name, substr(strrev(var.service_name), 0, 7))
  cidr_block = local.lb_subnet_1_subnet_cidr

  tags = {
    defined_tags  = local.defined_tags
    freeform_tags = local.free_form_tags
  }
}

/* Create secondary subnet for wls and lb backend */
module "network-lb-subnet-2" {
  source            = "./modules/network/subnet"
  count             = local.add_existing_load_balancer ? 0 : var.add_load_balancer && local.lb_subnet_2_id == "" && !var.is_lb_private && !local.use_regional_subnet && !local.is_single_ad_region ? 1 : 0
  compartment_id    = local.network_compartment_id
  vcn_id            = local.vcn_id
  security_list_ids = module.network-vcn-config[0].lb_security_list_id
  dhcp_options_id   = module.network-vcn-config[0].dhcp_options_id
  route_table_id    = module.network-vcn-config[0].route_table_id
  subnet_name       = "${local.service_name_prefix}-${local.lb_subnet_2_name}"
  #Note: limit for dns label is 15 chars
  dns_label  = format("%s-%s", local.lb_subnet_2_name, substr(strrev(var.service_name), 0, 7))
  cidr_block = local.lb_subnet_2_subnet_cidr

  tags = {
    defined_tags  = local.defined_tags
    freeform_tags = local.free_form_tags
  }

}

/* Create back end subnet for bastion subnet */
module "network-bastion-subnet" {
  source         = "./modules/network/subnet"
  count          = !local.assign_weblogic_public_ip && var.bastion_subnet_id == "" && var.is_bastion_instance_required && var.existing_bastion_instance_id == "" ? 1 : 0
  compartment_id = local.network_compartment_id
  vcn_id         = local.vcn_id
  security_list_ids = compact(
    concat(
      [module.network-vcn-config[0].wls_security_list_id],
      [module.network-vcn-config[0].wls_ms_security_list_id],
    ),
  )
  dhcp_options_id = module.network-vcn-config[0].dhcp_options_id
  route_table_id  = module.network-vcn-config[0].route_table_id
  subnet_name     = "${local.service_name_prefix}-${var.bastion_subnet_name}"
  dns_label       = "${var.bastion_subnet_name}-${substr(uuid(), -7, -1)}"
  cidr_block      = local.bastion_subnet_cidr

  tags = {
    defined_tags  = local.defined_tags
    freeform_tags = local.free_form_tags
  }
}

module "policies" {
  source                 = "./modules/policies"
  count                  = var.create_policies ? 1 : 0
  compartment_id         = var.compartment_id
  network_compartment_id = local.network_compartment_id
  dynamic_group_rule     = local.dynamic_group_rule
  resource_name_prefix   = local.service_name_prefix
  tenancy_id             = var.tenancy_id
  wls_admin_password_id  = var.wls_admin_password_id
  providers = {
    oci = oci.home
  }
  tags = {
    defined_tags  = local.defined_tags
    freeform_tags = local.free_form_tags
  }
  atp_db                    = local.atp_db
  oci_db                    = local.oci_db
  vcn_id                    = element(concat(module.network-vcn[*].vcn_id, [""]), 0)
  wls_existing_vcn_id       = var.wls_existing_vcn_id
  is_idcs_selected          = var.is_idcs_selected
  idcs_client_secret_id     = var.idcs_client_secret_id
  use_oci_logging           = var.use_oci_logging
  use_apm_service           = var.use_apm_service
  apm_domain_compartment_id = local.apm_domain_compartment_id
}


module "bastion" {
  source              = "./modules/compute/bastion"
  count               = (var.is_bastion_instance_required && var.existing_bastion_instance_id == "") ? 1 : 0
  availability_domain = local.bastion_availability_domain
  bastion_subnet_id   = var.bastion_subnet_id != "" ? var.bastion_subnet_id : module.network-bastion-subnet[0].subnet_id

  compartment_id      = var.compartment_id
  instance_image_id   = var.bastion_image_id
  instance_shape      = var.bastion_instance_shape
  region              = var.region
  ssh_public_key      = var.ssh_public_key
  tenancy_id          = var.tenancy_id
  use_existing_subnet = var.bastion_subnet_id != ""
  vm_count            = var.wls_node_count
  instance_name       = "${local.service_name_prefix}-bastion-instance"
  tags = {
    defined_tags  = local.defined_tags
    freeform_tags = local.free_form_tags
  }
  is_bastion_with_reserved_public_ip = var.is_bastion_with_reserved_public_ip

  use_bastion_marketplace_image       = var.use_bastion_marketplace_image
  mp_listing_id               = var.bastion_listing_id
  mp_listing_resource_version = var.bastion_listing_resource_version
}


/* Create back end  private subnet for wls */
module "network-wls-private-subnet" {
  source         = "./modules/network/subnet"
  count          = !local.assign_weblogic_public_ip && var.wls_subnet_id == "" ? 1 : 0
  compartment_id = local.network_compartment_id
  vcn_id         = local.vcn_id
  security_list_ids = compact(
    concat(
      module.network-vcn-config[0].wls_bastion_security_list_id,
      [module.network-vcn-config[0].wls_internal_security_list_id],
      [module.network-vcn-config[0].wls_ms_security_list_id]
    ),
  )
  dhcp_options_id = module.network-vcn-config[0].dhcp_options_id
  route_table_id  = module.network-vcn-config[0].service_gateway_route_table_id
  subnet_name     = "${local.service_name_prefix}-${var.wls_subnet_name}"
  dns_label       = format("%s-%s", var.wls_subnet_name, substr(strrev(var.service_name), 0, 7))
  cidr_block      = local.wls_subnet_cidr

  tags = {
    defined_tags  = local.defined_tags
    freeform_tags = local.free_form_tags
  }
}

/* Create back end  public subnet for wls */
module "network-wls-public-subnet" {
  source         = "./modules/network/subnet"
  count          = local.assign_weblogic_public_ip && var.wls_subnet_id == "" ? 1 : 0
  compartment_id = local.network_compartment_id
  vcn_id         = local.vcn_id
  security_list_ids = compact(
    concat(
      [module.network-vcn-config[0].wls_security_list_id],
      [module.network-vcn-config[0].wls_ms_security_list_id],
      [module.network-vcn-config[0].wls_internal_security_list_id]
    ),
  )

  dhcp_options_id = module.network-vcn-config[0].dhcp_options_id
  route_table_id  = module.network-vcn-config[0].route_table_id
  subnet_name     = "${local.service_name_prefix}-${var.wls_subnet_name}"
  dns_label       = format("%s-%s", var.wls_subnet_name, substr(strrev(var.service_name), 0, 7))
  cidr_block      = local.wls_subnet_cidr

  tags = {
    defined_tags  = local.defined_tags
    freeform_tags = local.free_form_tags
  }
}

/* Create private subnet for FSS */
module "network-mount-target-private-subnet" {
  source            = "./modules/network/subnet"
  count             = var.add_existing_mount_target ? 0 : (var.add_fss && var.mount_target_subnet_id == "" ? 1 : 0)
  compartment_id    = local.network_compartment_id
  vcn_id            = local.vcn_id
  security_list_ids = module.network-vcn-config[0].fss_security_list_id

  dhcp_options_id = module.network-vcn-config[0].dhcp_options_id
  route_table_id  = module.network-vcn-config[0].service_gateway_route_table_id
  subnet_name     = "${local.service_name_prefix}-mt-subnet"
  dns_label       = format("%s-%s", "mt-sbn", substr(strrev(var.service_name), 0, 7))
  cidr_block      = local.mount_target_subnet_cidr

  tags = {
    defined_tags  = local.defined_tags
    freeform_tags = local.free_form_tags
  }
}

module "validators" {
  source = "./modules/validators"

  service_name               = var.service_name
  wls_ms_port                = var.wls_ms_extern_port
  wls_ms_ssl_port            = var.wls_ms_extern_ssl_port
  wls_extern_admin_port      = var.wls_extern_admin_port
  wls_extern_ssl_admin_port  = var.wls_extern_ssl_admin_port
  wls_admin_port_source_cidr = var.wls_admin_port_source_cidr
  wls_expose_admin_port      = var.wls_expose_admin_port
  wls_version                = var.wls_version

  db_user                  = local.db_user
  db_password_id           = local.db_password_id
  is_oci_db                = local.is_oci_db
  oci_db_compartment_id    = local.oci_db_compartment_id
  oci_db_connection_string = var.oci_db_connection_string
  oci_db_database_id       = var.oci_db_database_id
  oci_db_dbsystem_id       = var.oci_db_dbsystem_id
  oci_db_existing_vcn_id   = var.oci_db_existing_vcn_id
  oci_db_pdb_service_name  = var.oci_db_pdb_service_name
  is_atp_db                = local.is_atp_db
  atp_db_id                = var.atp_db_id
  atp_db_compartment_id    = var.atp_db_compartment_id
  atp_db_level             = var.atp_db_level

  is_idcs_selected      = var.is_idcs_selected
  idcs_host             = var.idcs_host
  idcs_tenant           = var.idcs_tenant
  idcs_client_id        = var.idcs_client_id
  idcs_client_secret_id = var.idcs_client_secret_id
  idcs_cloudgate_port   = var.idcs_cloudgate_port

  existing_vcn_id              = var.wls_existing_vcn_id
  wls_subnet_cidr              = var.wls_subnet_cidr
  lb_subnet_1_cidr             = var.lb_subnet_1_cidr
  lb_subnet_2_cidr             = var.lb_subnet_2_cidr
  bastion_subnet_cidr          = var.bastion_subnet_cidr
  assign_public_ip             = local.assign_weblogic_public_ip
  is_bastion_instance_required = var.is_bastion_instance_required
  existing_bastion_instance_id = var.existing_bastion_instance_id
  bastion_ssh_private_key      = var.bastion_ssh_private_key
  add_load_balancer            = var.add_load_balancer
  existing_load_balancer_id    = var.existing_load_balancer_id

  wls_subnet_id     = var.wls_subnet_id
  lb_subnet_1_id    = var.lb_subnet_1_id
  lb_subnet_2_id    = ""
  bastion_subnet_id = var.bastion_subnet_id

  vcn_name            = var.wls_vcn_name
  use_regional_subnet = local.use_regional_subnet

  is_lb_private = var.is_lb_private

  add_fss                          = var.add_fss
  fss_availability_domain          = (var.add_existing_fss && var.add_existing_mount_target) ? data.oci_file_storage_file_systems.file_systems[0].file_systems[0].availability_domain : ""
  mount_target_subnet_id           = var.mount_target_subnet_id
  mount_target_subnet_cidr         = local.mount_target_subnet_cidr
  mount_target_compartment_id      = var.mount_target_compartment_id
  mount_target_id                  = var.mount_target_id
  existing_fss_id                  = var.existing_fss_id
  mount_target_availability_domain = var.add_existing_mount_target ? data.oci_file_storage_mount_targets.mount_targets[0].mount_targets[0].availability_domain : ""
  fss_compartment_id               = var.fss_compartment_id

  create_policies  = var.create_policies
  use_oci_logging  = var.use_oci_logging
  dynamic_group_id = var.dynamic_group_id

  use_apm_service           = var.use_apm_service
  apm_domain_id             = var.apm_domain_id
  apm_private_data_key_name = var.apm_private_data_key_name

}

module "fss" {
  source = "./modules/fss"
  count  = var.existing_fss_id == "" && var.add_fss ? 1 : 0

  compartment_id      = var.fss_compartment_id
  availability_domain = var.use_regional_subnet ? var.fss_availability_domain : data.oci_core_subnet.mount_target_subnet[0].availability_domain

  vcn_id                 = local.vcn_id
  vcn_cidr               = var.wls_vcn_cidr != "" ? var.wls_vcn_cidr : data.oci_core_vcn.wls_vcn[0].cidr_block
  resource_name_prefix   = var.service_name
  export_path            = local.export_path
  mount_target_id        = var.mount_target_id
  mount_target_subnet_id = var.use_existing_subnets ? var.mount_target_subnet_id : module.network-mount-target-private-subnet[0].subnet_id

  tags = {
    defined_tags  = local.defined_tags
    freeform_tags = local.free_form_tags
  }
}

module "load-balancer" {
  source = "./modules/lb/loadbalancer"
  count  = (var.add_load_balancer && var.existing_load_balancer_id == "") ? 1 : 0

  compartment_id           = local.network_compartment_id
  lb_reserved_public_ip_id = compact([var.lb_reserved_public_ip_id])
  is_lb_private            = var.is_lb_private
  lb_max_bandwidth         = var.lb_max_bandwidth
  lb_min_bandwidth         = var.lb_min_bandwidth
  lb_name                  = "${local.service_name_prefix}-lb"
  lb_subnet_1_id           = [var.lb_subnet_1_id]
  lb_subnet_2_id           = [var.lb_subnet_2_id]
  tags = {
    defined_tags  = local.defined_tags
    freeform_tags = local.free_form_tags
  }
}

module "observability-common" {
  source = "./modules/observability/common"
  count  = var.use_oci_logging ? 1 : 0

  compartment_id      = var.compartment_id
  service_prefix_name = local.service_name_prefix
}

module "compute" {
  source                 = "./modules/compute/wls_compute"
  add_loadbalancer       = var.add_load_balancer
  is_lb_private          = var.is_lb_private
  load_balancer_id       = var.add_load_balancer ? (var.existing_load_balancer_id != "" ? var.existing_load_balancer_id : element(coalescelist(module.load-balancer[*].wls_loadbalancer_id, [""]), 0)) : ""
  assign_public_ip       = var.assign_weblogic_public_ip
  availability_domain    = local.wls_availability_domain
  compartment_id         = var.compartment_id
  instance_image_id      = var.instance_image_id
  instance_shape         = var.instance_shape
  wls_ocpu_count         = var.wls_ocpu_count
  network_compartment_id = var.network_compartment_id
  wls_subnet_cidr        = local.wls_subnet_cidr
  subnet_id              = local.assign_weblogic_public_ip ? (var.wls_subnet_id != "" ? var.wls_subnet_id : element(concat(module.network-wls-public-subnet[*].subnet_id, [""]), 0)) : (var.wls_subnet_id != "" ? var.wls_subnet_id : element(concat(module.network-wls-private-subnet[*].subnet_id, [""]), 0))
  wls_subnet_id          = var.wls_subnet_id
  region                 = var.region
  ssh_public_key         = var.ssh_public_key

  tenancy_id              = var.tenancy_id
  tf_script_version       = var.tf_script_version
  use_regional_subnet     = var.use_regional_subnet
  wls_14c_jdk_version     = var.wls_14c_jdk_version
  wls_admin_password_id   = var.wls_admin_password_id
  wls_admin_server_name   = format("%s_adminserver", local.service_name_prefix)
  wls_ms_server_name      = format("%s_server_", local.service_name_prefix)
  wls_admin_user          = var.wls_admin_user
  wls_domain_name         = format("%s_domain", local.service_name_prefix)
  wls_server_startup_args = var.wls_server_startup_args
  wls_existing_vcn_id     = var.wls_existing_vcn_id
  wls_vcn_cidr            = var.wls_vcn_cidr != "" ? var.wls_vcn_cidr : module.network-vcn[0].vcn_cidr
  wls_version             = var.wls_version
  wls_edition             = var.wls_edition
  num_vm_instances        = var.wls_node_count
  resource_name_prefix    = var.service_name

  is_idcs_selected      = var.is_idcs_selected
  idcs_host             = var.idcs_host
  idcs_port             = var.idcs_port
  idcs_tenant           = var.idcs_tenant
  idcs_client_id        = var.idcs_client_id
  idcs_cloudgate_port   = var.idcs_cloudgate_port
  idcs_app_prefix       = local.service_name_prefix
  idcs_client_secret_id = var.idcs_client_secret_id

  lbip = local.lb_ip

  add_fss     = var.add_fss
  mount_ip    = element(concat(module.fss[*].mount_ip, [""]), 0)
  mount_path  = var.mount_path
  export_path = var.existing_export_path_id != "" ? element(concat(data.oci_file_storage_exports.export[*].exports[0].path, [""]), 0) : element(concat(module.fss[*].export_path, [""]), 0)

  db_existing_vcn_add_seclist = var.ocidb_existing_vcn_add_seclist
  jrf_parameters = {
    db_user        = local.db_user
    db_password_id = local.db_password_id
    atp_db_parameters = {
      atp_db_id    = var.atp_db_id
      atp_db_level = var.atp_db_level
    }
    oci_db_parameters = {
      oci_db_connection_string      = var.oci_db_connection_string
      oci_db_compartment_id         = local.oci_db_compartment_id
      oci_db_dbsystem_id            = trimspace(var.oci_db_dbsystem_id)
      oci_db_database_id            = var.oci_db_database_id
      oci_db_pdb_service_name       = var.oci_db_pdb_service_name
      oci_db_port                   = var.oci_db_port
      oci_db_network_compartment_id = local.oci_db_network_compartment_id
      oci_db_existing_vcn_id        = var.oci_db_existing_vcn_id
    }
  }

  log_group_id    = element(concat(module.observability-common[*].log_group_id, [""]), 0)
  use_oci_logging = var.use_oci_logging

  use_apm_service           = var.use_apm_service
  apm_domain_compartment_id = local.apm_domain_compartment_id
  apm_domain_id             = var.apm_domain_id
  apm_private_data_key_name = var.apm_private_data_key_name

  use_marketplace_image       = var.use_marketplace_image
  mp_listing_id               = var.listing_id
  mp_listing_resource_version = var.listing_resource_version

  tags = {
    defined_tags    = local.defined_tags
    freeform_tags   = local.free_form_tags
    dg_defined_tags = local.dg_defined_tags
  }
}

module "load-balancer-backends" {
  source = "./modules/lb/backends"
  count  = var.add_load_balancer ? 1 : 0

  health_check_url     = "/"
  instance_private_ips = module.compute.instance_private_ips
  lb_port              = var.wls_ms_extern_port #TODO: change name of this variable lb_port to be more descriptive
  load_balancer_id     = var.add_load_balancer ? (var.existing_load_balancer_id != "" ? var.existing_load_balancer_id : element(coalescelist(module.load-balancer[*].wls_loadbalancer_id, [""]), 0)) : ""
  num_vm_instances     = var.wls_node_count
  resource_name_prefix = local.service_name_prefix
  # TODO: check if we can add support to tags
  /*tags = {
    defined_tags = local.defined_tags
    freeform_tags = local.free_form_tags
  }*/
}

module "observability-logging" {
  source = "./modules/observability/logging"
  count  = var.use_oci_logging ? 1 : 0

  compartment_id                        = var.compartment_id
  oci_managed_instances_principal_group = element(concat(module.policies[*].oci_managed_instances_principal_group, [""]), 0)
  service_prefix_name                   = local.service_name_prefix
  create_policies                       = var.create_policies
  use_oci_logging                       = var.use_oci_logging
  dynamic_group_id                      = var.dynamic_group_id
  log_group_id                          = module.observability-common[0].log_group_id

  tags = {
    defined_tags  = local.defined_tags
    freeform_tags = local.free_form_tags
  }
}

module "provisioners" {
  source = "./modules/provisioners"

  existing_bastion_instance_id = var.existing_bastion_instance_id
  host_ips                     = coalescelist(compact(module.compute.instance_public_ips), compact(module.compute.instance_private_ips), [""])
  num_vm_instances             = var.wls_node_count
  ssh_private_key              = module.compute.ssh_private_key_opc
  assign_public_ip             = var.assign_weblogic_public_ip
  bastion_host                 = !var.is_bastion_instance_required ? "" : var.existing_bastion_instance_id == "" ? module.bastion[0].public_ip : data.oci_core_instance.existing_bastion_instance[0].public_ip
  bastion_host_private_key     = !var.is_bastion_instance_required ? "" : var.existing_bastion_instance_id == "" ? module.bastion[0].bastion_private_ssh_key : file(var.bastion_ssh_private_key)
  is_bastion_instance_required = var.is_bastion_instance_required
}
