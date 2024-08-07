# Copyright (c) 2023, 2024, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

output "virtual_cloud_network_id" {
  value = var.wls_existing_vcn_id != "" ? var.wls_existing_vcn_id : module.network-vcn[0].vcn_id
}

output "virtual_cloud_network_cidr" {
  value = var.wls_vcn_name == "" ? data.oci_core_vcn.wls_vcn[0].cidr_block : element(concat(module.network-vcn.*.vcn_cidr, tolist([""])), 0)
}

output "is_vcn_peered" {
  value = local.is_vcn_peering
}

output "fss_system_id" {
  value = var.existing_fss_id != "" ? var.existing_fss_id : (var.add_fss ? module.fss[0].fss_id : "")
}

output "mount_target_id" {
  value = var.add_fss ? (var.mount_target_id != "" ? var.mount_target_id : module.fss[0].mount_target_id) : ""
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

output "webLogic_server_domain_configuration" {
  value = local.wls_domain_configuration
}

output "weblogic_server_administration_console" {
  value = local.admin_console_app_url
}

output "fusion_middleware_control_console" {
  value = local.fmw_console_app_url
}

output "sample_application" {
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

output "rms_private_endpoint_id" {
  value = var.is_rms_private_endpoint_required ? local.add_new_rms_private_endpoint ? module.rms-private-endpoint[0].rms_private_endpoint_id : var.rms_existing_private_endpoint_id : ""
}

output "weblogic_agent_configuration_id" {
  value = element(concat(module.observability-logging[*].agent_config_id, [""]), 0)
}

output "weblogic_log_group_id" {
  value = element(concat(module.observability-common[*].log_group_id, [""]), 0)
}

output "weblogic_log_id" {
  value = element(concat(module.observability-logging[*].log_id, [""]), 0)
}

output "ssh_command" {
  value = local.ssh_proxyjump_access
}

output "ssh_command_with_dynamic_port_forwarding" {
  value = local.ssh_dp_fwd
}

output "resource_identifier_value" {
  value = compact(concat([module.system-tags.dg_tag_value], local.user_defined_tag_values))
}

output "autoscaling_scaleout_monitoring_alarm_id" {
  value = element(concat(module.observability-autoscaling[*].scaleout_monitoring_alarm, [""]), 0)
}

output "autoscaling_scalein_monitoring_alarm_id" {
  value = element(concat(module.observability-autoscaling[*].scalein_monitoring_alarm, [""]), 0)
}

output "autoscaling_function_application_id" {
  value = element(concat(module.observability-autoscaling[*].autoscaling_function_application_id, [""]), 0)
}
