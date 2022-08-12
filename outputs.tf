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

output "webLogic_instances" {
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

output "webLogic_version" {
  value = format(
    "%s %s %s",
    module.compute.wls_version,
    local.edition_map[upper(var.wls_edition)],
    local.prov_type,
  )
}


