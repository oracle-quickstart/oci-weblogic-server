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

module "policies" {
  source                 = "./modules/policies"
  count                  = var.create_policies ? 1 : 0
  compartment_id         = var.compartment_id
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
  atp_db = local.atp_db
  is_idcs_selected      = var.is_idcs_selected
  idcs_client_secret_id = var.idcs_client_secret_id
}

module "bastion" {
  source              = "./modules/compute/bastion"
  count               = (var.is_bastion_instance_required && var.existing_bastion_instance_id == "") ? 1 : 0
  availability_domain = local.bastion_availability_domain
  bastion_subnet_id   = var.bastion_subnet_id # TODO : implement case where a new subnet is created
  compartment_id      = var.compartment_id
  instance_image_id   = var.use_baselinux_marketplace_image ? var.mp_baselinux_instance_image_id : var.bastion_instance_image_id
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
}

module "validators" {
  source                     = "./modules/validators"
  service_name               = var.service_name
  wls_ms_port                = var.wls_ms_extern_port
  wls_ms_ssl_port            = var.wls_ms_extern_ssl_port
  wls_extern_admin_port      = var.wls_extern_admin_port
  wls_extern_ssl_admin_port  = var.wls_extern_ssl_admin_port
  wls_admin_port_source_cidr = var.wls_admin_port_source_cidr
  wls_expose_admin_port      = var.wls_expose_admin_port

  add_load_balancer          = var.add_load_balancer
  is_idcs_selected           = var.is_idcs_selected
  idcs_host                  = var.idcs_host
  idcs_tenant                = var.idcs_tenant
  idcs_client_id             = var.idcs_client_id
  idcs_client_secret_id      = var.idcs_client_secret_id
  idcs_cloudgate_port        = var.idcs_cloudgate_port
}

module load-balancer {
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
  subnet_id              = var.wls_subnet_id
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
  wls_vcn_cidr            = var.wls_vcn_cidr
  wls_subnet_cidr         = "" # TODO add variable to set this when support for new VCN and subnet is added
  wls_version             = var.wls_version
  wls_edition             = var.wls_edition
  num_vm_instances        = var.wls_node_count
  resource_name_prefix    = var.service_name

  is_idcs_selected        = var.is_idcs_selected
  idcs_host               = var.idcs_host
  idcs_port               = var.idcs_port
  idcs_tenant             = var.idcs_tenant
  idcs_client_id          = var.idcs_client_id
  idcs_cloudgate_port     = var.idcs_cloudgate_port
  idcs_app_prefix         = local.service_name_prefix
  idcs_client_secret_id   = var.idcs_client_secret_id

  lbip = local.lb_ip

  db_existing_vcn_add_seclist = var.ocidb_existing_vcn_add_seclist
  jrf_parameters = {
    db_user        = local.db_user
    db_password_id = local.db_password
    atp_db_parameters = {
      atp_db_id    = var.atp_db_id
      atp_db_level = var.atp_db_level
    }
  }

  tags = {
    defined_tags    = local.defined_tags
    freeform_tags   = local.free_form_tags
    dg_defined_tags = local.dg_defined_tags
  }
}

module load-balancer-backends {
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

module "provisioners" {
  source = "./modules/provisioners"

  existing_bastion_instance_id = var.existing_bastion_instance_id
  host_ips                     = coalescelist(compact(module.compute.instance_public_ips), compact(module.compute.instance_private_ips), [""])
  num_vm_instances             = var.wls_node_count
  ssh_private_key              = module.compute.ssh_private_key_opc
  assign_public_ip             = var.assign_weblogic_public_ip
  bastion_host                 = ! var.is_bastion_instance_required ? "" : var.existing_bastion_instance_id == "" ? module.bastion[0].public_ip : data.oci_core_instance.existing_bastion_instance[0].public_ip
  bastion_host_private_key     = ! var.is_bastion_instance_required ? "" : var.existing_bastion_instance_id == "" ? module.bastion[0].bastion_private_ssh_key : file(var.bastion_ssh_private_key)
  is_bastion_instance_required = var.is_bastion_instance_required
}