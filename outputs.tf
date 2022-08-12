output "bastion_public_ip" {
  value = module.bastion.*.public_ip
}

output "weblogic_compute_private_ip" {
  value = module.compute.instance_private_ips
}


