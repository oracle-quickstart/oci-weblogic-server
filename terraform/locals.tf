# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  service_name_prefix = replace(var.service_name, "/[^a-zA-Z0-9]/", "")

  home_region                  = lookup(data.oci_identity_regions.home_region.regions[0], "name")
  ad_names                     = compact(data.template_file.ad_names.*.rendered)
  export_path                  = format("/%s", var.service_name)
  vm_instance_image_id         = var.terms_and_conditions ? var.ucm_instance_image_id : var.instance_image_id
  add_existing_mount_target    = (var.add_existing_mount_target || var.add_existing_fss)
  bastion_availability_domain  = var.bastion_subnet_id != "" ? (local.use_regional_subnet ? var.wls_availability_domain_name != "" ? var.wls_availability_domain_name : local.ad_names[0] : data.oci_core_subnet.bastion_subnet[0].availability_domain) : (local.use_regional_subnet ? var.wls_availability_domain_name != "" ? var.wls_availability_domain_name : local.ad_names[0] : var.wls_availability_domain_name)
  wls_availability_domain      = local.use_regional_subnet ? (var.wls_availability_domain_name == "" ? local.ad_names[0] : var.wls_availability_domain_name) : (var.wls_subnet_id == "" ? var.wls_availability_domain_name : data.oci_core_subnet.wls_subnet[0].availability_domain)
  lb_availability_domain_name1 = var.lb_subnet_1_id != "" ? (local.use_regional_subnet ? "" : data.oci_core_subnet.lb_subnet_1_id[0].availability_domain) : ""
  lb_availability_domain_name2 = var.lb_subnet_2_id != "" ? (local.use_regional_subnet ? "" : data.oci_core_subnet.lb_subnet_2_id[0].availability_domain) : ""
  fss_availability_domain      = var. add_fss ? (local.use_regional_subnet ? var.fss_availability_domain : (!var.add_existing_fss && !local.add_existing_mount_target ? data.oci_core_subnet.mount_target_subnet[0].availability_domain : var.fss_availability_domain)) : ""
  network_compartment_id       = var.network_compartment_id == "" ? var.compartment_ocid : var.network_compartment_id

  #dynamic group is based on the system generated tags for DG
  create_dg_tags     = var.create_policies && var.generate_dg_tag && var.mode == "PROD" # Only create dynamic group tags in PROD mode when create policies and generate dg tag is true
  dg_system_tags_key = local.create_dg_tags ? format("%s.%s", module.system-tags.tag_namespace, module.system-tags.dg_tag_key) : ""
  dynamic_group_rule = local.create_dg_tags ? format("%s.%s.%s='%s'", "tag", local.dg_system_tags_key, "value", module.system-tags.dg_tag_value) : length(var.service_tags.definedTags) > 0 ? format("tag.%s.value='%s'", keys(var.service_tags.definedTags)[0], values(var.service_tags.definedTags)[0]) : ""
  dg_defined_tags    = local.create_dg_tags ? zipmap([local.dg_system_tags_key], [module.system-tags.dg_tag_value]) : {}
  defined_tags       = var.service_tags.definedTags
  free_form_tags     = length(var.service_tags.freeformTags) > 0 ? var.service_tags.freeformTags : module.system-tags.system_tag_value

  db_user                       = local.is_atp_db ? "ADMIN" : var.oci_db_user
  db_password_id                = local.is_atp_db ? var.atp_db_password_id : var.oci_db_password_id
  is_atp_db                     = trimspace(var.atp_db_id) != ""
  is_atp_with_private_endpoints = local.is_atp_db && (length(data.oci_database_autonomous_database.atp_db) != 0 ? data.oci_database_autonomous_database.atp_db[0].subnet_id != null : false)
  atp_db_network_compartment_id = local.is_atp_db && var.atp_db_network_compartment_id == "" ? var.atp_db_compartment_id : var.atp_db_network_compartment_id

  atp_db = {
    is_atp         = local.is_atp_db
    compartment_id = var.atp_db_compartment_id
    password_id    = var.atp_db_password_id
  }
  oci_db = {
    is_oci_db                = local.is_oci_db
    password_id              = var.oci_db_password_id
    compartment_id           = local.oci_db_compartment_id
    network_compartment_id   = local.oci_db_network_compartment_id
    existing_vcn_id          = var.oci_db_existing_vcn_id
    oci_db_connection_string = var.oci_db_connection_string
    existing_vcn_add_seclist = local.is_oci_db ? var.ocidb_existing_vcn_add_seclist : false
  }

  is_oci_db                     = trimspace(var.oci_db_dbsystem_id) == "" ? false : true
  oci_db_compartment_id         = var.oci_db_compartment_id == "" ? local.network_compartment_id : var.oci_db_compartment_id
  oci_db_network_compartment_id = local.is_oci_db && var.oci_db_network_compartment_id == "" ? var.oci_db_compartment_id : var.oci_db_network_compartment_id

  db_network_compartment_id = local.is_atp_db ? local.atp_db_network_compartment_id : local.oci_db_network_compartment_id

  # Locals used by outputs
  bastion_public_ip = element(coalescelist(module.bastion[*].public_ip, data.oci_core_instance.existing_bastion_instance.*.public_ip, [""]), 0)
  requires_JRF      = local.is_oci_db || local.is_atp_db || trimspace(var.oci_db_connection_string) != ""
  prov_type         = local.requires_JRF ? local.is_atp_db ? "(JRF with ATP DB)" : "(JRF with OCI DB)" : "(Non JRF)"
  edition_map = zipmap(
    ["SE", "EE", "SUITE"],
    ["Standard Edition", "Enterprise Edition", "Suite Edition"],
  )

  new_lb_ip                  = !var.add_load_balancer || local.use_existing_lb ? "" : element(coalescelist(module.load-balancer[0].wls_loadbalancer_ip_addresses, [""]), 0)
  new_lb_id                  = element(concat(module.load-balancer[*].wls_loadbalancer_id, [""]), 0)
  existing_lb_ip             = local.use_existing_lb && local.valid_existing_lb ? local.existing_lb_object_as_list[0].ip_addresses[0] : ""
  existing_lb_object_as_list = [for lb in data.oci_load_balancer_load_balancers.existing_load_balancers_data_source.load_balancers[*] : lb if lb.id == var.existing_load_balancer_id]
  valid_existing_lb          = length(local.existing_lb_object_as_list) == 1
  use_existing_lb            = var.add_load_balancer && var.existing_load_balancer_id != ""
  lb_backendset_name         = local.use_existing_lb ? var.backendset_name_for_existing_load_balancer : "${local.service_name_prefix}-lb-backendset"
  existing_lb_subnet_1_id    = local.use_existing_lb && local.valid_existing_lb ? local.existing_lb_object_as_list[0].subnet_ids[0] : ""
  existing_lb_subnet_2_id    = local.use_existing_lb && local.valid_existing_lb ? (var.is_lb_private ? "" : (length(local.existing_lb_object_as_list[0].subnet_ids) > 1 ? local.existing_lb_object_as_list[0].subnet_ids[1] : "")) : ""
  new_lb_subnet_2_id         = var.is_lb_private ? "" : var.lb_subnet_2_id
  lb_subnet_2_id             = local.use_existing_lb ? local.existing_lb_subnet_2_id : local.new_lb_subnet_2_id

  lb_subnet_1_name = var.is_lb_private ? "lbprist1" : "lbpubst1"
  lb_subnet_2_name = var.is_lb_private ? "lbprist2" : "lbpubst2"


  lb_id = local.use_existing_lb ? var.existing_load_balancer_id : local.new_lb_id
  lb_ip = local.use_existing_lb ? local.existing_lb_ip : local.new_lb_ip

  assign_weblogic_public_ip = var.assign_weblogic_public_ip || var.subnet_type == "Use Public Subnet"

  admin_ip_address      = local.assign_weblogic_public_ip ? module.compute.instance_public_ips[0] : module.compute.instance_private_ips[0]
  admin_console_app_url = format("https://%s:%s/console", local.admin_ip_address, var.wls_extern_ssl_admin_port)
  sample_app_protocol   = var.add_load_balancer ? "https" : "http"
  sample_app_url_lb_ip  = var.deploy_sample_app && var.add_load_balancer ? format("%s://%s/sample-app", local.sample_app_protocol, local.lb_ip) : ""
  sample_app_url_wls_ip = var.deploy_sample_app ? format("https://%s:%s/sample-app", local.admin_ip_address, var.wls_ms_extern_ssl_port) : ""
  sample_app_url        = var.wls_edition != "SE" ? (var.deploy_sample_app && var.add_load_balancer ? local.sample_app_url_lb_ip : local.sample_app_url_wls_ip) : ""
  sample_idcs_app_url = var.deploy_sample_app && var.add_load_balancer && var.is_idcs_selected ? format(
    "%s://%s/__protected/idcs-sample-app",
    local.sample_app_protocol,
    local.lb_ip,
  ) : ""

  async_prov_mode = !local.assign_weblogic_public_ip && !var.is_bastion_instance_required ? "Asynchronous provisioning is enabled. Connect to each compute instance and confirm that the file /u01/data/domains/${format("%s_domain", local.service_name_prefix)}/provisioningCompletedMarker exists. Details are found in the file /u01/logs/provisioning.log." : ""

  jdk_labels  = { jdk7 = "JDK 7", jdk8 = "JDK 8", jdk11 = "JDK 11" }
  jdk_version = var.wls_version == "14.1.1.0" ? local.jdk_labels[var.wls_14c_jdk_version] : (var.wls_version == "11.1.1.7" ? local.jdk_labels["jdk7"] : local.jdk_labels["jdk8"])

  user_defined_tag_values = values(var.service_tags.definedTags)

  ssh_proxyjump_access = local.assign_weblogic_public_ip || !var.is_bastion_instance_required ? "" : format("ssh -i <privateKey> -o ProxyCommand=\"ssh -i <privateKey> -W %s -p 22 opc@%s\" -p 22 %s", "%h:%p", local.bastion_public_ip, "opc@<wls_vm_private_ip>")
  ssh_dp_fwd           = local.assign_weblogic_public_ip || !var.is_bastion_instance_required ? "" : format("ssh -i <privatekey> -C -D <local-port> opc@%s", local.bastion_public_ip)

  use_existing_subnets = var.wls_subnet_id == "" && var.lb_subnet_1_id == "" && var.lb_subnet_2_id == "" ? false : true

  // Criteria for VCN peering:
  // 1. Only when both WLS VCN name is provided (wls_vcn_name) and DB VCN ID is provided (either oci_db_existing_vcn_id or atp_db_existing_vcn_id)
  // 2. or when both WLS VCN ID is provided (wls_existing_vcn_id) and DB VCN ID is provided (either oci_db_existing_vcn_id or atp_db_existing_vcn_id) and they are different IDs,
  // and not using existing subnets (local.use_existing_subnets)

  new_vcn_and_oci_db                    = var.wls_vcn_name != "" && local.is_oci_db && var.oci_db_existing_vcn_id != ""
  existing_vcn_and_oci_db_different_vcn = var.wls_existing_vcn_id != "" && var.oci_db_existing_vcn_id != "" && var.wls_existing_vcn_id != var.oci_db_existing_vcn_id

  new_vcn_and_atp_db_private_endpoint                    = var.wls_vcn_name != "" && local.is_atp_with_private_endpoints && var.atp_db_existing_vcn_id != ""
  existing_vcn_and_atp_db_private_endpoint_different_vcn = var.wls_existing_vcn_id != "" && local.is_atp_with_private_endpoints && var.atp_db_existing_vcn_id != "" && var.wls_existing_vcn_id != var.atp_db_existing_vcn_id

  is_vcn_peering = local.new_vcn_and_oci_db || local.new_vcn_and_atp_db_private_endpoint || ((local.existing_vcn_and_oci_db_different_vcn || local.existing_vcn_and_atp_db_private_endpoint_different_vcn) && !local.use_existing_subnets)

  bastion_subnet_cidr      = var.bastion_subnet_cidr == "" && var.wls_vcn_name != "" && !local.assign_weblogic_public_ip ? "10.0.1.0/24" : var.bastion_subnet_cidr
  wls_subnet_cidr          = var.wls_subnet_cidr == "" && var.wls_vcn_name != "" ? "10.0.2.0/24" : var.wls_subnet_cidr
  lb_subnet_1_subnet_cidr  = var.lb_subnet_1_cidr == "" && var.wls_vcn_name != "" ? "10.0.3.0/24" : var.lb_subnet_1_cidr
  mount_target_subnet_cidr = var.mount_target_subnet_cidr == "" && var.wls_vcn_name != "" ? "10.0.5.0/24" : var.mount_target_subnet_cidr

  num_ads = length(
    data.oci_identity_availability_domains.ADs.availability_domains,
  )
  is_single_ad_region = local.num_ads == 1 ? true : false
  use_regional_subnet = (var.use_regional_subnet && var.subnet_span == "Regional Subnet")
  vcn_id              = var.wls_existing_vcn_id == "" ? module.network-vcn[0].vcn_id : var.wls_existing_vcn_id

  fmw_console_app_url = local.requires_JRF ? format(
    "https://%s:%s/em",
    local.admin_ip_address,
    var.wls_extern_ssl_admin_port,
  ) : ""

  apm_domain_compartment_id = var.use_apm_service ? lookup(data.oci_apm_apm_domain.apm_domain[0], "compartment_id") : ""

  ocir_namespace = data.oci_objectstorage_namespace.object_namespace.namespace

  ocir_user           = format("%s/%s", local.ocir_namespace, var.ocir_user)
  region_keys         = data.oci_identity_regions.all_regions.regions.*.key
  region_names        = data.oci_identity_regions.all_regions.regions.*.name
  ocir_region         = var.ocir_region == "" ? lower(element(local.region_keys, index(local.region_names, lower(var.region)))) : var.ocir_region
  ocir_region_url     = format("%s.ocir.io", local.ocir_region)
  fn_repo_name        = format("%s_autoscaling_function_repo", lower(local.service_name_prefix))
  fn_repo_path        = format("%s/%s/%s", local.ocir_region_url, local.ocir_namespace, local.fn_repo_name)
  fn_application_name = format("%s_autoscaling_function_application", local.service_name_prefix)

  existing_compute_nsg_ids = var.add_existing_nsg ? [var.existing_admin_server_nsg_id, var.existing_managed_server_nsg_id] : []
  compute_nsg_ids          = local.use_existing_subnets ? local.existing_compute_nsg_ids : concat(module.network-compute-admin-nsg[0].nsg_id, module.network-compute-managed-nsg[0].nsg_id)

  # TODO: remove these two vars when UI uses control with flex shape
  instance_shape = {
    "instanceShape" = var.instance_shape,
    "ocpus"         = var.wls_ocpu_count
  }

  bastion_instance_shape = {
    "instanceShape" = var.bastion_instance_shape,
    "ocpus"         = 1
  }
}
