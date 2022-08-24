# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  service_name_prefix = replace(var.service_name, "/[^a-zA-Z0-9]/", "")

  home_region = lookup(data.oci_identity_regions.home_region.regions[0], "name")
  ad_names    = compact(data.template_file.ad_names.*.rendered)

  bastion_availability_domain = var.bastion_subnet_id != "" ? (var.use_regional_subnet ? var.wls_availability_domain_name != "" ? var.wls_availability_domain_name : local.ad_names[0] : data.oci_core_subnet.bastion_subnet[0].availability_domain) : (var.use_regional_subnet ? var.wls_availability_domain_name != "" ? var.wls_availability_domain_name : local.ad_names[0] : var.wls_availability_domain_name)
  wls_availability_domain     = var.use_regional_subnet ? (var.wls_availability_domain_name == "" ? local.ad_names[0] : var.wls_availability_domain_name) : (var.wls_subnet_id == "" ? var.wls_availability_domain_name : data.oci_core_subnet.wls_subnet[0].availability_domain)
  network_compartment_id      = var.network_compartment_id == "" ? var.compartment_id : var.network_compartment_id

  #dynamic group is based on the system generated tags for DG
  create_dg_tags     = var.create_policies && var.generate_dg_tag # Only create dynamic group tags when create policies and generate dg tag is true
  dg_system_tags_key = local.create_dg_tags ? format("%s.%s", module.system-tags.tag_namespace, module.system-tags.dg_tag_key) : ""
  dynamic_group_rule = local.create_dg_tags ? format("%s.%s.%s='%s'", "tag", local.dg_system_tags_key, "value", module.system-tags.dg_tag_value) : length(var.service_tags.definedTags) > 0 ? format("tag.%s.value='%s'", keys(var.service_tags.definedTags)[0], values(var.service_tags.definedTags)[0]) : ""
  dg_defined_tags    = local.create_dg_tags ? zipmap([local.dg_system_tags_key], [module.system-tags.dg_tag_value]) : {}
  defined_tags       = var.service_tags.definedTags
  free_form_tags     = length(var.service_tags.freeformTags) > 0 ? var.service_tags.freeformTags : module.system-tags.system_tag_value

  db_user     = local.is_atp_db ? "ADMIN" : ""
  db_password = local.is_atp_db ? var.atp_db_password_id : ""
  is_atp_db   = trimspace(var.atp_db_id) != ""
  atp_db = {
    is_atp         = local.is_atp_db
    compartment_id = var.atp_db_compartment_id
    password_id    = var.atp_db_password_id
  }

  # Locals used by outputs
  bastion_public_ip = element(coalescelist(module.bastion[*].public_ip, data.oci_core_instance.existing_bastion_instance.*.public_ip, [""]), 0)
  requires_JRF      = local.is_atp_db
  prov_type         = local.requires_JRF ? local.is_atp_db ? "(JRF with ATP DB)" : "" : "(Non JRF)"
  edition_map = zipmap(
    ["SE", "EE", "SUITE"],
    ["Standard Edition", "Enterprise Edition", "Suite Edition"],
  )

  new_lb_ip                  = local.add_existing_load_balancer ? "" : element(element(coalescelist(module.load-balancer[*].wls_loadbalancer_ip_addresses, [""]), 0), 0)
  new_lb_id                  = element(concat(module.load-balancer[*].wls_loadbalancer_id, [""]), 0)
  existing_lb_ip             = local.add_existing_load_balancer ? local.existing_lb_object_as_list[0].ip_addresses[0] : ""
  existing_lb_object_as_list = [for lb in data.oci_load_balancer_load_balancers.existing_load_balancers_data_source.load_balancers[*] : lb if lb.id == var.existing_load_balancer_id]
  valid_existing_lb          = length(local.existing_lb_object_as_list) == 1
  add_existing_load_balancer = var.add_load_balancer && var.existing_load_balancer_id != "" && local.valid_existing_lb

  new_lb_subnet_2_id = var.is_lb_private ? "" : var.lb_subnet_2_id
  lb_subnet_2_id = local.add_existing_load_balancer ? local.existing_lb_subnet_2_id : local.new_lb_subnet_2_id

  lb_id                      = local.add_existing_load_balancer ? var.existing_load_balancer_id : local.new_lb_id
  lb_ip                      = local.add_existing_load_balancer ? local.existing_lb_ip : local.new_lb_ip

  admin_ip_address      = var.assign_weblogic_public_ip ? module.compute.instance_public_ips[0] : module.compute.instance_private_ips[0]
  admin_console_app_url = format("https://%s:%s/console", local.admin_ip_address, var.wls_extern_ssl_admin_port)
  sample_app_protocol   = var.add_load_balancer ? "https" : "http"
  sample_app_url_lb_ip  = var.deploy_sample_app && var.add_load_balancer ? format("%s://%s/sample-app", local.sample_app_protocol, local.lb_ip) : ""
  sample_app_url_wls_ip = var.deploy_sample_app ? format("https://%s:%s/sample-app", local.admin_ip_address, var.wls_ms_extern_ssl_port) : ""
  sample_app_url        = var.wls_edition != "SE" ? (var.deploy_sample_app && var.add_load_balancer ? local.sample_app_url_lb_ip : local.sample_app_url_wls_ip) : ""

  async_prov_mode = ! var.is_bastion_instance_required ? "Asynchronous provisioning is enabled. Connect to each compute instance and confirm that the file /u01/data/domains/${format("%s_domain", local.service_name_prefix)}/provisioningCompletedMarker exists. Details are found in the file /u01/logs/provisioning.log." : ""

  jdk_labels  = { jdk7 = "JDK 7", jdk8 = "JDK 8", jdk11 = "JDK 11" }
  jdk_version = var.wls_version == "14.1.1.0" ? local.jdk_labels[var.wls_14c_jdk_version] : (var.wls_version == "11.1.1.7" ? local.jdk_labels["jdk7"] : local.jdk_labels["jdk8"])

  user_defined_tag_values = values(var.service_tags.definedTags)

  ssh_proxyjump_access = var.assign_weblogic_public_ip ? "" : format("ssh -i <privateKey> -o ProxyCommand=\"ssh -i <privateKey> -W %s -p 22 opc@%s\" -p 22 %s", "%h:%p", local.bastion_public_ip, "opc@<wls_vm_private_ip>")
  ssh_dp_fwd           = var.assign_weblogic_public_ip ? "" : format("ssh -i <privatekey> -C -D <local-port> opc@%s", local.bastion_public_ip)

  use_existing_subnets = var.wls_subnet_id == "" && var.lb_subnet_1_id == "" && var.lb_subnet_2_id == "" ? false : true
  is_vcn_peering        = false
  bastion_subnet_cidr      = var.bastion_subnet_cidr == "" && var.wls_vcn_name != "" && ! local.assign_weblogic_public_ip ? local.is_vcn_peering ? "11.0.1.0/24" : "10.0.1.0/24" : var.bastion_subnet_cidr
  wls_subnet_cidr          = var.wls_subnet_cidr == "" && var.wls_vcn_name != "" ? local.is_vcn_peering ? "11.0.2.0/24" : "10.0.2.0/24" : var.wls_subnet_cidr
  lb_subnet_1_subnet_cidr  = var.lb_subnet_1_cidr == "" && var.wls_vcn_name != "" ? local.is_vcn_peering ? "11.0.3.0/24" : "10.0.3.0/24" : var.lb_subnet_1_cidr
  lb_subnet_2_subnet_cidr  = var.lb_subnet_2_cidr == "" && var.wls_vcn_name != "" ? local.is_vcn_peering ? "11.0.4.0/24" : "10.0.4.0/24" : var.lb_subnet_2_cidr
  num_ads = length(
    data.oci_identity_availability_domains.ADs.availability_domains,
  )
  is_single_ad_region = local.num_ads == 1 ? true : false
  use_regional_subnet    = (var.use_regional_subnet && var.subnet_span == "Regional Subnet")
  vcn_id = var.wls_existing_vcn_id=="" ? module.network-vcn[0].vcn_id : var.wls_existing_vcn_id

}
