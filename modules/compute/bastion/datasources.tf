# Gets a list of Availability Domains in the tenancy
data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_id
}

data "template_file" "bastion_key_script" {
  template = file("${path.module}/templates/bastion-keys.tpl")

  vars = {
    pubKey = local.bastion_public_ssh_key
  }
}

data "oci_core_shapes" "oci_shapes" {
  #Required
  compartment_id      = var.compartment_id
  image_id            = var.instance_image_id
  availability_domain = var.availability_domain
  filter {
    name   = "name"
    values = [var.instance_shape]
  }
}

data "oci_core_private_ips" "bastion_private_ips" {
  count = var.is_bastion_with_reserved_public_ip ? 1 : 0

  ip_address = oci_core_instance.wls-bastion-instance[0].private_ip
  subnet_id  = var.bastion_subnet_id
}