# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

output "virtual_cloud_network_id" {
  value = var.wls_existing_vcn_id != "" ? var.wls_existing_vcn_id : module.network-vcn[0].vcn_id
}

output "virtual_cloud_network_cidr" {
  value = var.wls_existing_vcn_id != "" ? var.wls_vcn_cidr : module.network-vcn[0].vcn_cidr
}

output "is_vcn_peered" {
  value = local.is_vcn_peering
}

output "load_balancer_subnets_id" {
  value = compact(
    concat(
      [var.lb_subnet_1_id],
      [var.lb_subnet_2_id]
    ),
  )
}

output "weblogic_subnet_id" {
  value = var.wls_subnet_id
}

output "load_balancer_id" {
  value = local.lb_id
}

output "load_balancer_ip" {
  value = local.lb_ip
}

output "bastion_instance_id" {
  value = element(concat(module.bastion[*].id, data.oci_core_instance.existing_bastion_instance.*.id, [""]), 0)
}

output "bastion_instance_public_ip" {
  value = local.bastion_public_ip
}

output "weblogic_instances" {
  value = jsonencode(formatlist(
    "{ Instance Id:%s, Instance name:%s, Availability Domain:%s, Instance Shape:%s, Private IP:%s, Public IP:%s }",
    module.compute.instance_ids,
    module.compute.display_names,
    module.compute.availability_domains,
    module.compute.instance_shapes,
    module.compute.instance_private_ips,
    module.compute.instance_public_ips,
  ))
}

output "weblogic_version" {
  value = format(
    "%s %s %s",
    module.compute.wls_version,
    local.edition_map[upper(var.wls_edition)],
    local.prov_type,
  )
}

output "weblogic_server_administration_console" {
  value = local.admin_console_app_url
}

output "fusion_middleware_control_console" {
  value = local.fmw_console_app_url
}

output "sample_application_url" {
  value = local.sample_app_url
}

output "sample_application_protected_by_idcs" {
  value = local.sample_idcs_app_url
}

output "listing_version" {
  value = var.tf_script_version
}

output "provisioning_status" {
  value = local.async_prov_mode
}

output "jdk_version" {
  value = local.jdk_version
}

output "webLogic_agent_configuration_id" {
  value = element(concat(module.observability-logging[*].agent_config_id, [""]), 0)
}

output "webLogic_log_group_id" {
  value = element(concat(module.observability-common[*].log_group_id, [""]), 0)
}

output "webLogic_log_id" {
  value = element(concat(module.observability-logging[*].log_id, [""]), 0)
}

output "ssh_command" {
  value = local.ssh_proxyjump_access
}

output "ssh_command_with_dynamic_port_forwarding" {
  value = local.ssh_dp_fwd
}

output "fss_system_id" {
  value = module.fss[*].fss_id
}

output "resource_identifier_value" {
  value = compact(concat([module.system-tags.dg_tag_value], local.user_defined_tag_values))
}
