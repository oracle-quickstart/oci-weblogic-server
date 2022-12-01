# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

module "system-tags" {
  source         = "./modules/resource-tags"
  compartment_id = var.compartment_ocid
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
  assign_backend_public_ip   = local.assign_weblogic_public_ip

  wls_security_list_name       = !local.assign_weblogic_public_ip ? "bastion-security-list" : "wls-security-list"
  wls_subnet_cidr              = local.wls_subnet_cidr
  wls_ms_source_cidrs          = local.add_load_balancer ? [local.lb_subnet_1_subnet_cidr] : ["0.0.0.0/0"]
  load_balancer_min_value      = local.add_load_balancer ? var.wls_ms_extern_port : var.wls_ms_extern_ssl_port
  load_balancer_max_value      = local.add_load_balancer ? var.wls_ms_extern_port : var.wls_ms_extern_ssl_port
  create_load_balancer         = local.add_load_balancer
  resource_name_prefix         = local.service_name_prefix
  bastion_subnet_cidr          = local.bastion_subnet_cidr
  is_bastion_instance_required = var.is_bastion_instance_required
  existing_bastion_instance_id = var.existing_bastion_instance_id
  vcn_cidr                     = var.wls_vcn_name == "" ? data.oci_core_vcn.wls_vcn[0].cidr_block : element(concat(module.network-vcn.*.vcn_cidr, tolist([""])), 0)
  existing_mt_subnet_id        = var.mount_target_subnet_id
  existing_service_gateway_ids = var.wls_vcn_name != "" ? [] : data.oci_core_service_gateways.service_gateways.service_gateways.*.id
  existing_nat_gateway_ids     = var.wls_vcn_name != "" ? [] : data.oci_core_nat_gateways.nat_gateways.nat_gateways.*.id
  create_nat_gateway           = var.is_idcs_selected && var.wls_vcn_name != ""
  create_service_gateway       = var.wls_vcn_name != ""
  create_internet_gateway      = var.wls_vcn_name != ""
  lb_destination_cidr          = var.is_lb_private ? local.bastion_subnet_cidr : "0.0.0.0/0"
  add_fss                      = var.add_fss
  add_existing_mount_target    = local.add_existing_mount_target
  add_existing_fss             = var.add_existing_fss
  # If the module is empty (count is zero), an empty list is returned. If not, a list of lists of strings is returned.
  # By using flatten we make sure each entry in the map is a list of string, either with one element, or empty
  nsg_ids = {
    lb_nsg_id           = flatten(module.network-lb-nsg[*].nsg_id)
    bastion_nsg_id      = flatten(module.network-bastion-nsg[*].nsg_id)
    mount_target_nsg_id = flatten(module.network-mount-target-nsg[*].nsg_id)
    admin_nsg_id        = flatten(module.network-compute-admin-nsg[*].nsg_id)
    managed_nsg_id      = flatten(module.network-compute-managed-nsg[*].nsg_id)
  }

  tags = {
    defined_tags  = local.defined_tags
    freeform_tags = local.free_form_tags
  }
}

module "network-lb-nsg" {
  source         = "./modules/network/nsg"
  count          = local.use_existing_lb ? 0 : local.add_load_balancer && !local.use_existing_subnets && local.lb_subnet_1_subnet_cidr != "" ? 1 : 0
  compartment_id = local.network_compartment_id
  vcn_id         = local.vcn_id
  nsg_name       = "${local.service_name_prefix}-lb-nsg"

  tags = {
    defined_tags  = local.defined_tags
    freeform_tags = local.free_form_tags
  }
}

module "network-bastion-nsg" {
  source         = "./modules/network/nsg"
  count          = var.is_bastion_instance_required && var.existing_bastion_instance_id == "" && !local.use_existing_subnets && local.bastion_subnet_cidr != "" ? 1 : 0
  compartment_id = local.network_compartment_id
  vcn_id         = local.vcn_id
  nsg_name       = "${local.service_name_prefix}-bastion-nsg"

  tags = {
    defined_tags  = local.defined_tags
    freeform_tags = local.free_form_tags
  }
}

module "network-mount-target-nsg" {
  source         = "./modules/network/nsg"
  count          = var.add_fss && !local.use_existing_subnets && local.mount_target_subnet_cidr != "" ? 1 : 0
  compartment_id = local.network_compartment_id
  vcn_id         = local.vcn_id
  nsg_name       = "${local.service_name_prefix}-mount-target-nsg"

  tags = {
    defined_tags  = local.defined_tags
    freeform_tags = local.free_form_tags
  }
}

module "network-compute-admin-nsg" {
  source         = "./modules/network/nsg"
  count          = !local.use_existing_subnets && local.wls_subnet_cidr != "" ? 1 : 0
  compartment_id = local.network_compartment_id
  vcn_id         = local.vcn_id
  nsg_name       = "${local.service_name_prefix}-admin-server-nsg"

  tags = {
    defined_tags  = local.defined_tags
    freeform_tags = local.free_form_tags
  }
}

module "network-compute-managed-nsg" {
  source         = "./modules/network/nsg"
  count          = !local.use_existing_subnets && local.wls_subnet_cidr != "" ? 1 : 0
  compartment_id = local.network_compartment_id
  vcn_id         = local.vcn_id
  nsg_name       = "${local.service_name_prefix}-managed-server-nsg"

  tags = {
    defined_tags  = local.defined_tags
    freeform_tags = local.free_form_tags
  }
}

/* Create primary subnet for Load balancer only */
module "network-lb-subnet-1" {
  source          = "./modules/network/subnet"
  count           = local.use_existing_lb ? 0 : local.add_load_balancer && var.lb_subnet_1_id == "" ? 1 : 0
  compartment_id  = local.network_compartment_id
  vcn_id          = local.vcn_id
  dhcp_options_id = module.network-vcn-config[0].dhcp_options_id
  route_table_id  = module.network-vcn-config[0].route_table_id

  subnet_name = "${local.service_name_prefix}-${local.lb_subnet_1_name}"
  #Note: limit for dns label is 15 chars
  dns_label          = format("%s-%s", local.lb_subnet_1_name, substr(strrev(var.service_name), 0, 7))
  cidr_block         = local.lb_subnet_1_subnet_cidr
  prohibit_public_ip = var.is_lb_private

  tags = {
    defined_tags  = local.defined_tags
    freeform_tags = local.free_form_tags
  }
}

/* Create back end subnet for bastion subnet */
module "network-bastion-subnet" {
  source             = "./modules/network/subnet"
  count              = !local.assign_weblogic_public_ip && var.bastion_subnet_id == "" && var.is_bastion_instance_required && var.existing_bastion_instance_id == "" ? 1 : 0
  compartment_id     = local.network_compartment_id
  vcn_id             = local.vcn_id
  dhcp_options_id    = length(module.network-vcn-config) > 0 ? module.network-vcn-config[0].dhcp_options_id : ""
  route_table_id     = length(module.network-vcn-config) > 0 ? module.network-vcn-config[0].route_table_id : ""
  subnet_name        = "${local.service_name_prefix}-${var.bastion_subnet_name}"
  dns_label          = "${var.bastion_subnet_name}-${substr(uuid(), -7, -1)}"
  cidr_block         = local.bastion_subnet_cidr
  prohibit_public_ip = false

  tags = {
    defined_tags  = local.defined_tags
    freeform_tags = local.free_form_tags
  }
}

module "policies" {
  source                 = "./modules/policies"
  count                  = var.create_policies ? 1 : 0
  compartment_id         = var.compartment_ocid
  network_compartment_id = local.network_compartment_id
  dynamic_group_rule     = local.dynamic_group_rule
  resource_name_prefix   = local.service_name_prefix
  tenancy_id             = var.tenancy_ocid
  wls_admin_password_id  = var.wls_admin_password_id
  providers = {
    oci = oci.home
  }
  tags = {
    defined_tags  = local.defined_tags
    freeform_tags = local.free_form_tags
  }
  atp_db                      = local.atp_db
  oci_db                      = local.oci_db
  vcn_id                      = element(concat(module.network-vcn[*].vcn_id, [""]), 0)
  wls_existing_vcn_id         = var.wls_existing_vcn_id
  is_idcs_selected            = var.is_idcs_selected
  idcs_client_secret_id       = var.idcs_client_secret_id
  use_oci_logging             = var.use_oci_logging
  use_apm_service             = local.use_apm_service
  apm_domain_compartment_id   = local.apm_domain_compartment_id
  use_autoscaling             = var.use_autoscaling
  ocir_auth_token_id          = var.ocir_auth_token_id
  add_fss                     = var.add_fss
  add_load_balancer           = local.add_load_balancer
  fss_compartment_id          = var.fss_compartment_id == "" ? var.compartment_ocid : var.fss_compartment_id
  mount_target_compartment_id = var.mount_target_compartment_id == "" ? var.compartment_ocid : var.mount_target_compartment_id
}


module "bastion" {
  source              = "./modules/compute/bastion"
  count               = (!local.assign_weblogic_public_ip && var.is_bastion_instance_required && var.existing_bastion_instance_id == "") ? 1 : 0
  availability_domain = local.bastion_availability_domain
  bastion_subnet_id   = var.bastion_subnet_id != "" ? var.bastion_subnet_id : module.network-bastion-subnet[0].subnet_id

  compartment_id      = var.compartment_ocid
  instance_image_id   = var.bastion_image_id
  instance_shape      = local.bastion_instance_shape
  region              = var.region
  ssh_public_key      = var.ssh_public_key
  tenancy_id          = var.tenancy_ocid
  use_existing_subnet = var.bastion_subnet_id != ""
  vm_count            = var.wls_node_count
  instance_name       = "${local.service_name_prefix}-bastion-instance"
  tags = {
    defined_tags  = local.defined_tags
    freeform_tags = local.free_form_tags
  }
  is_bastion_with_reserved_public_ip = var.is_bastion_with_reserved_public_ip
  bastion_nsg_id                     = var.bastion_subnet_id != "" ? (var.add_existing_nsg ? [var.existing_bastion_nsg_id] : []) : flatten(module.network-bastion-nsg[*].nsg_id)

  use_bastion_marketplace_image = var.use_bastion_marketplace_image
  mp_listing_id                 = var.bastion_listing_id
  mp_listing_resource_version   = var.bastion_listing_resource_version
}


/* Create back end  private subnet for wls */
module "network-wls-private-subnet" {
  source          = "./modules/network/subnet"
  count           = !local.assign_weblogic_public_ip && var.wls_subnet_id == "" ? 1 : 0
  compartment_id  = local.network_compartment_id
  vcn_id          = local.vcn_id
  dhcp_options_id = module.network-vcn-config[0].dhcp_options_id
  #This is to prevent Terraform from resetting the route table on reapply. Peering module will set a new route table
  route_table_id     = local.is_vcn_peering ? "" : module.network-vcn-config[0].service_gateway_route_table_id
  subnet_name        = "${local.service_name_prefix}-${var.wls_subnet_name}"
  dns_label          = format("%s-%s", var.wls_subnet_name, substr(strrev(var.service_name), 0, 7))
  cidr_block         = local.wls_subnet_cidr
  prohibit_public_ip = true

  tags = {
    defined_tags  = local.defined_tags
    freeform_tags = local.free_form_tags
  }
}

/* Create back end  public subnet for wls */
module "network-wls-public-subnet" {
  source             = "./modules/network/subnet"
  count              = local.assign_weblogic_public_ip && var.wls_subnet_id == "" ? 1 : 0
  compartment_id     = local.network_compartment_id
  vcn_id             = local.vcn_id
  dhcp_options_id    = module.network-vcn-config[0].dhcp_options_id
  route_table_id     = module.network-vcn-config[0].route_table_id
  subnet_name        = "${local.service_name_prefix}-${var.wls_subnet_name}"
  dns_label          = format("%s-%s", var.wls_subnet_name, substr(strrev(var.service_name), 0, 7))
  cidr_block         = local.wls_subnet_cidr
  prohibit_public_ip = false

  tags = {
    defined_tags  = local.defined_tags
    freeform_tags = local.free_form_tags
  }
}

/* Create private subnet for FSS */
module "network-mount-target-private-subnet" {
  source         = "./modules/network/subnet"
  count          = var.add_fss && !local.add_existing_mount_target && !var.add_existing_fss && var.mount_target_subnet_id == "" ? 1 : 0
  compartment_id = local.network_compartment_id
  vcn_id         = local.vcn_id

  dhcp_options_id    = module.network-vcn-config[0].dhcp_options_id
  route_table_id     = module.network-vcn-config[0].service_gateway_route_table_id
  subnet_name        = "${local.service_name_prefix}-mt-subnet"
  dns_label          = format("%s-%s", "mt-sbn", substr(strrev(var.service_name), 0, 7))
  cidr_block         = local.mount_target_subnet_cidr
  prohibit_public_ip = true

  tags = {
    defined_tags  = local.defined_tags
    freeform_tags = local.free_form_tags
  }
}

module "vcn-peering" {
  count                          = local.is_vcn_peering ? 1 : 0
  source                         = "./modules/network/vcn-peering"
  resource_name_prefix           = local.service_name_prefix
  wls_network_compartment_id     = local.network_compartment_id
  wls_vcn_id                     = local.vcn_id
  is_existing_wls_vcn            = var.wls_existing_vcn_id != ""
  is_wls_subnet_public           = local.assign_weblogic_public_ip
  wls_subnet_id                  = var.wls_subnet_id != "" ? var.wls_subnet_id : local.assign_weblogic_public_ip ? element(concat(module.network-wls-public-subnet[*].subnet_id, [""]), 0) : element(concat(module.network-wls-private-subnet[*].subnet_id, [""]), 0)
  wls_service_gateway_id         = var.wls_vcn_name == "" ? data.oci_core_service_gateways.service_gateways.service_gateways[0].id : element(concat(module.network-vcn-config[*].wls_service_gateway_services_id, [""]), 0)
  wls_internet_gateway_id        = var.wls_vcn_name == "" ? data.oci_core_internet_gateways.internet_gateways.gateways[0].id : element(concat(module.network-vcn-config[*].wls_internet_gateway_id, [""]), 0)
  db_vcn_id                      = local.is_oci_db ? var.oci_db_existing_vcn_id : var.atp_db_existing_vcn_id
  db_subnet_id                   = local.is_oci_db ? data.oci_database_db_systems.ocidb_db_systems[0].db_systems[0].subnet_id : local.is_atp_with_private_endpoints ? data.oci_database_autonomous_database.atp_db[0].subnet_id : ""
  db_vcn_lpg_id                  = var.db_vcn_lpg_id
  wait_time_wls_vnc_dns_resolver = var.wait_time_wls_vnc_dns_resolver
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
  num_vm_instances           = var.wls_node_count
  wls_node_count_limit       = var.wls_node_count_limit

  db_user                       = local.db_user
  db_password_id                = local.db_password_id
  db_vcn_lpg_id                 = var.db_vcn_lpg_id
  db_network_compartment_id     = local.db_network_compartment_id
  is_vcn_peering                = local.is_vcn_peering
  is_oci_db                     = local.is_oci_db
  oci_db_compartment_id         = local.oci_db_compartment_id
  oci_db_connection_string      = var.oci_db_connection_string
  oci_db_database_id            = var.oci_db_database_id
  oci_db_dbsystem_id            = var.oci_db_dbsystem_id
  oci_db_existing_vcn_id        = var.oci_db_existing_vcn_id
  oci_db_pdb_service_name       = var.oci_db_pdb_service_name
  is_atp_db                     = local.is_atp_db
  atp_db_id                     = var.atp_db_id
  atp_db_compartment_id         = var.atp_db_compartment_id
  atp_db_level                  = var.atp_db_level
  atp_db_existing_vcn_id        = var.atp_db_existing_vcn_id
  is_atp_with_private_endpoints = local.is_atp_with_private_endpoints

  is_idcs_selected      = var.is_idcs_selected
  idcs_host             = var.idcs_host
  idcs_tenant           = var.idcs_tenant
  idcs_client_id        = var.idcs_client_id
  idcs_client_secret_id = var.idcs_client_secret_id
  idcs_cloudgate_port   = var.idcs_cloudgate_port

  network_compartment_id       = local.network_compartment_id
  existing_vcn_id              = var.wls_existing_vcn_id
  wls_subnet_cidr              = var.wls_subnet_cidr
  lb_subnet_1_cidr             = var.lb_subnet_1_cidr
  bastion_subnet_cidr          = local.bastion_subnet_cidr
  assign_public_ip             = local.assign_weblogic_public_ip
  is_bastion_instance_required = var.is_bastion_instance_required
  existing_bastion_instance_id = var.existing_bastion_instance_id
  bastion_ssh_private_key      = var.bastion_ssh_private_key

  use_existing_subnets = local.use_existing_subnets

  lb_availability_domain_name1 = local.lb_availability_domain_name1
  lb_availability_domain_name2 = local.lb_availability_domain_name2
  wls_subnet_id                = var.wls_subnet_id
  lb_subnet_1_id               = var.lb_subnet_1_id
  lb_subnet_2_id               = local.lb_subnet_2_id
  bastion_subnet_id            = var.bastion_subnet_id

  vcn_name            = var.wls_vcn_name
  use_regional_subnet = local.use_regional_subnet

  add_load_balancer                          = local.add_load_balancer
  is_lb_private                              = var.is_lb_private
  existing_load_balancer_id                  = var.existing_load_balancer_id
  existing_load_balancer_found               = length(local.existing_lb_object_as_list) == 1
  backendset_name_for_existing_load_balancer = var.backendset_name_for_existing_load_balancer
  existing_lb_subnet_1_id                    = local.existing_lb_subnet_1_id
  existing_lb_subnet_2_id                    = local.existing_lb_subnet_2_id

  add_fss                              = var.add_fss
  fss_availability_domain_existing_fss = var.add_existing_fss && var.existing_fss_id != "" ? data.oci_file_storage_file_systems.file_systems[0].file_systems[0].availability_domain : ""
  fss_availability_domain              = var.fss_availability_domain
  mount_target_subnet_id               = var.mount_target_subnet_id
  mount_target_subnet_cidr             = local.mount_target_subnet_cidr
  mount_target_compartment_id          = var.mount_target_compartment_id
  mount_target_id                      = var.mount_target_id
  existing_fss_id                      = var.existing_fss_id
  mount_target_availability_domain     = local.add_existing_mount_target ? data.oci_file_storage_mount_targets.mount_targets[0].mount_targets[0].availability_domain : ""

  create_policies  = var.create_policies
  use_oci_logging  = var.use_oci_logging
  dynamic_group_id = var.dynamic_group_id

  use_apm_service           = local.use_apm_service
  apm_domain_id             = var.apm_domain_id
  apm_private_data_key_name = var.apm_private_data_key_name

  use_autoscaling = var.use_autoscaling
  wls_metric      = var.wls_metric

  ocir_auth_token_id    = var.ocir_auth_token_id
  max_threshold_counter = var.max_threshold_counter
  max_threshold_percent = var.max_threshold_percent
  min_threshold_counter = var.min_threshold_counter
  min_threshold_percent = var.min_threshold_percent

  generate_dg_tag = var.generate_dg_tag
  service_tags    = var.service_tags
  tags = {
    defined_tags  = local.defined_tags
    freeform_tags = local.free_form_tags
  }

  wlsoci_vmscripts_zip_bundle_path = var.wlsoci_vmscripts_zip_bundle_path
  mode                             = var.mode

  image_mode             = var.image_mode
  instance_image_id      = var.instance_image_id
  ucm_instance_image_id  = var.ucm_instance_image_id
  terms_and_conditions   = var.terms_and_conditions
  ucm_instance_count     = length(data.oci_core_instances.ucm_instances.instances.*.display_name)
  provisioned_node_count = length(data.oci_core_instances.provisioned_instances.instances.*.display_name)
  use_marketplace_image  = var.use_marketplace_image
  wls_edition            = var.wls_edition
}

module "fss" {
  source = "./modules/fss"
  count  = var.add_fss ? 1 : 0

  compartment_id      = var.compartment_ocid
  availability_domain = local.fss_availability_domain

  vcn_id                      = local.vcn_id
  vcn_cidr                    = var.wls_vcn_cidr != "" ? var.wls_vcn_cidr : data.oci_core_vcn.wls_vcn[0].cidr_block
  resource_name_prefix        = var.service_name
  export_path                 = local.export_path
  existing_fss_id             = var.existing_fss_id
  mount_target_id             = var.mount_target_id
  mount_target_compartment_id = var.mount_target_compartment_id == "" ? var.compartment_ocid : var.mount_target_compartment_id
  mount_target_subnet_id      = local.use_existing_subnets ? var.mount_target_subnet_id : (local.add_existing_mount_target ? "" : module.network-mount-target-private-subnet[0].subnet_id)
  mount_target_nsg_id         = var.mount_target_subnet_id != "" || local.add_existing_mount_target ? (var.add_existing_nsg ? [var.existing_mount_target_nsg_id] : []) : element(module.network-mount-target-nsg[*].nsg_id, 0)
  tags = {
    defined_tags  = local.defined_tags
    freeform_tags = local.free_form_tags
  }
}

module "load-balancer" {
  source = "./modules/lb/loadbalancer"
  count  = (local.add_load_balancer && var.existing_load_balancer_id == "") ? 1 : 0

  compartment_id           = local.network_compartment_id
  lb_reserved_public_ip_id = compact([var.lb_reserved_public_ip_id])
  is_lb_private            = var.is_lb_private
  lb_nsg_id                = var.lb_subnet_1_id != "" ? (var.add_existing_nsg ? [var.existing_lb_nsg_id] : []) : element(module.network-lb-nsg[*].nsg_id, 0)
  lb_max_bandwidth         = var.lb_max_bandwidth
  lb_min_bandwidth         = var.lb_min_bandwidth
  lb_name                  = "${local.service_name_prefix}-lb"
  lb_subnet_1_id           = var.lb_subnet_1_id != "" ? [var.lb_subnet_1_id] : [module.network-lb-subnet-1[0].subnet_id]
  lb_subnet_2_id           = [var.lb_subnet_2_id]

  tags = {
    defined_tags  = local.defined_tags
    freeform_tags = local.free_form_tags
  }
}

module "observability-common" {
  source = "./modules/observability/common"
  count  = var.use_oci_logging ? 1 : 0

  compartment_id      = var.compartment_ocid
  service_prefix_name = local.service_name_prefix
  add_delay           = var.use_autoscaling
}

module "observability-autoscaling" {
  source = "./modules/observability/autoscaling"
  count  = var.use_autoscaling ? 1 : 0

  compartment_id        = var.compartment_ocid
  metric_compartment_id = local.apm_domain_compartment_id
  service_prefix_name   = local.service_name_prefix
  subscription_endpoint = var.notification_email
  alarm_severity        = var.alarm_severity
  min_threshold_percent = var.min_threshold_percent
  max_threshold_percent = var.max_threshold_percent
  min_threshold_counter = var.min_threshold_counter
  max_threshold_counter = var.max_threshold_counter
  wls_metric            = var.wls_metric
  wls_subnet_id         = var.wls_subnet_id != "" ? var.wls_subnet_id : local.assign_weblogic_public_ip ? element(concat(module.network-wls-public-subnet[*].subnet_id, [""]), 0) : element(concat(module.network-wls-private-subnet[*].subnet_id, [""]), 0)
  wls_node_count        = var.wls_node_count
  tenancy_id            = var.tenancy_ocid

  fn_application_name = local.fn_application_name
  fn_repo_name        = local.fn_repo_name
  log_group_id        = element(concat(module.observability-common[*].log_group_id, [""]), 0)
  create_policies     = var.create_policies
  use_oci_logging     = var.use_oci_logging

  tags = {
    defined_tags  = local.defined_tags
    freeform_tags = local.free_form_tags
  }
}


module "compute" {
  source                 = "./modules/compute/wls_compute"
  add_loadbalancer       = local.add_load_balancer
  is_lb_private          = var.is_lb_private
  load_balancer_id       = local.add_load_balancer ? (var.existing_load_balancer_id != "" ? var.existing_load_balancer_id : element(coalescelist(module.load-balancer[*].wls_loadbalancer_id, [""]), 0)) : ""
  assign_public_ip       = local.assign_weblogic_public_ip
  availability_domain    = local.wls_availability_domain
  compartment_id         = var.compartment_ocid
  instance_image_id      = local.vm_instance_image_id
  is_ucm_image           = var.terms_and_conditions
  instance_shape         = local.instance_shape
  network_compartment_id = var.network_compartment_id
  wls_subnet_cidr        = local.wls_subnet_cidr
  subnet_id              = var.wls_subnet_id != "" ? var.wls_subnet_id : local.assign_weblogic_public_ip ? element(concat(module.network-wls-public-subnet[*].subnet_id, [""]), 0) : element(concat(module.network-wls-private-subnet[*].subnet_id, [""]), 0)
  wls_subnet_id          = var.wls_subnet_id
  region                 = var.region
  ssh_public_key         = var.ssh_public_key
  compute_nsg_ids        = local.compute_nsg_ids

  tenancy_id                = var.tenancy_ocid
  tf_script_version         = var.tf_script_version
  use_regional_subnet       = local.use_regional_subnet
  wls_14c_jdk_version       = var.wls_14c_jdk_version
  wls_admin_user            = var.wls_admin_user
  wls_admin_password_id     = var.wls_admin_password_id
  wls_admin_server_name     = format("%s_adminserver", local.service_name_prefix)
  wls_ms_server_name        = format("%s_server_", local.service_name_prefix)
  wls_nm_port               = var.wls_nm_port
  wls_ms_port               = var.wls_ms_port
  wls_ms_ssl_port           = var.wls_ms_ssl_port
  wls_ms_extern_ssl_port    = var.wls_ms_extern_ssl_port
  wls_ms_extern_port        = var.wls_ms_extern_port
  wls_cluster_name          = format("%s_cluster", local.service_name_prefix)
  wls_machine_name          = format("%s_machine_", local.service_name_prefix)
  wls_extern_admin_port     = var.wls_extern_admin_port
  wls_extern_ssl_admin_port = var.wls_extern_ssl_admin_port
  wls_admin_port            = var.wls_admin_port
  wls_admin_ssl_port        = var.wls_admin_ssl_port
  wls_domain_name           = format("%s_domain", local.service_name_prefix)
  wls_server_startup_args   = var.wls_server_startup_args
  wls_existing_vcn_id       = var.wls_existing_vcn_id

  #The following two are for adding a dependency on the peering module
  wls_vcn_peering_dns_resolver_id           = element(flatten(concat(module.vcn-peering[*].wls_vcn_dns_resolver_id, [""])), 0)
  wls_vcn_peering_route_table_attachment_id = local.assign_weblogic_public_ip ? element(flatten(concat(module.vcn-peering[*].wls_vcn_public_route_table_attachment_id, [""])), 0) : element(flatten(concat(module.vcn-peering[*].wls_vcn_private_route_table_attachment_id, [""])), 0)

  mount_vcn_id                  = var.mount_target_id != "" ? data.oci_core_subnet.mount_target_existing_subnet[0].vcn_id : ""
  wls_vcn_cidr                  = var.wls_vcn_cidr != "" ? var.wls_vcn_cidr : element(concat(module.network-vcn.*.vcn_cidr, tolist([""])), 0)
  wls_version                   = var.wls_version
  wls_edition                   = var.wls_edition
  allow_manual_domain_extension = var.allow_manual_domain_extension
  num_vm_instances              = var.wls_node_count
  resource_name_prefix          = var.service_name

  deploy_sample_app = local.deploy_sample_app

  is_bastion_instance_required = var.is_bastion_instance_required

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
  mount_ip    = var.existing_fss_id != "" ? element(concat(data.oci_core_private_ip.mount_target_private_ips.*.ip_address, [""]), 0) : element(concat(module.fss[*].mount_ip, [""]), 0)
  mount_path  = var.mount_path
  export_path = local.export_path

  db_existing_vcn_add_seclist = var.db_existing_vcn_add_secrule
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

  // Dev or Prod mode
  mode = var.mode

  log_group_id    = element(concat(module.observability-common[*].log_group_id, [""]), 0)
  use_oci_logging = var.use_oci_logging

  use_apm_service           = local.use_apm_service
  apm_domain_compartment_id = local.apm_domain_compartment_id
  apm_domain_id             = var.apm_domain_id
  apm_private_data_key_name = var.apm_private_data_key_name

  scalein_notification_topic_id  = element(concat(module.observability-autoscaling[*].scalein_notification_topic_id, [""]), 0)
  scaleout_notification_topic_id = element(concat(module.observability-autoscaling[*].scaleout_notification_topic_id, [""]), 0)

  ocir_auth_token_id = var.ocir_auth_token_id
  ocir_url           = local.ocir_region_url
  ocir_user          = local.ocir_user
  fn_repo_path       = local.fn_repo_path
  fn_application_id  = element(concat(module.observability-autoscaling[*].autoscaling_function_application_id, [""]), 0)
  use_autoscaling    = var.use_autoscaling

  use_marketplace_image       = var.use_marketplace_image
  mp_listing_id               = var.listing_id
  mp_listing_resource_version = var.listing_resource_version

  mp_ucm_listing_id               = var.ucm_listing_id
  mp_ucm_listing_resource_version = var.ucm_listing_resource_version

  tags = {
    defined_tags    = local.defined_tags
    freeform_tags   = local.free_form_tags
    dg_defined_tags = local.dg_defined_tags
  }
}

module "load-balancer-backends" {
  source = "./modules/lb/backends"
  count  = local.add_load_balancer ? 1 : 0

  resource_name_prefix = local.service_name_prefix
  load_balancer_id     = local.add_load_balancer ? (var.existing_load_balancer_id != "" ? var.existing_load_balancer_id : element(coalescelist(module.load-balancer[*].wls_loadbalancer_id, [""]), 0)) : ""
  use_existing_lb      = local.use_existing_lb
  lb_backendset_name   = local.lb_backendset_name
  num_vm_instances     = var.wls_node_count
  instance_private_ips = module.compute.instance_private_ips
  backend_port         = var.is_idcs_selected ? var.idcs_cloudgate_port : var.wls_ms_extern_port
  health_check_url     = var.is_idcs_selected ? "/cloudgate" : "/"
}

module "observability-logging" {
  source = "./modules/observability/logging"
  count  = var.use_oci_logging ? 1 : 0

  compartment_id                        = var.compartment_ocid
  oci_managed_instances_principal_group = element(concat(module.policies[*].oci_managed_instances_principal_group, [""]), 0)
  service_prefix_name                   = local.service_name_prefix
  create_policies                       = var.create_policies
  dynamic_group_id                      = var.dynamic_group_id
  log_group_id                          = module.observability-common[0].log_group_id
  use_oci_logging                       = var.use_oci_logging
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
  assign_public_ip             = local.assign_weblogic_public_ip
  bastion_host                 = local.assign_weblogic_public_ip || !var.is_bastion_instance_required ? "" : var.existing_bastion_instance_id == "" ? module.bastion[0].public_ip : data.oci_core_instance.existing_bastion_instance[0].public_ip
  bastion_host_private_key     = local.assign_weblogic_public_ip || !var.is_bastion_instance_required ? "" : var.existing_bastion_instance_id == "" ? module.bastion[0].bastion_private_ssh_key : file(var.bastion_ssh_private_key)
  is_bastion_instance_required = var.is_bastion_instance_required

  mode                             = var.mode
  wlsoci_vmscripts_zip_bundle_path = var.wlsoci_vmscripts_zip_bundle_path
}
