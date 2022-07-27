variable "ssh_public_key" {
  type        = string
  description = "public key for ssh access to WebLogic instances"
}

variable "tenancy_id" {}

variable "region" {
  default = "us-phoenix-1"
}

module "system-tags" {
  source            = "../../modules/resource-tags"
  compartment_id    = "ocid1.compartment.oc1..aaaaaaaa5yqmecwmpytnntr6ktcrcgbon575ktozpuxbzzpvs67c2pziax4a"
  service_name      = "nonjrf-instance"
  is_system_tag     = true
  create_dg_tags    = true
  providers = {
    oci = oci.home
  }
}

module "policies" {
  source = "../../modules/policies"
  count = 1
  compartment_id = "ocid1.compartment.oc1..aaaaaaaa5yqmecwmpytnntr6ktcrcgbon575ktozpuxbzzpvs67c2pziax4a"
  dynamic_group_rule = local.dynamic_group_rule
  resource_name_prefix = "nonjrf-instance"
  tenancy_id = var.tenancy_id
  wls_admin_password_id = "ocid1.vaultsecret.oc1.phx.amaaaaaa3vsvjwaarqchhgbpblyqec5bdjjbjuykx5uqy5a3tji7qt6xpjdq"
  providers = {
    oci = oci.home
  }
  tags = {
    defined_tags = {}
    freeform_tags = module.system-tags.system_tag_value
  }
}

module "non-JRF" {
  source = "../../modules/compute/wls_compute"
  add_loadbalancer = false
  assign_public_ip = false
  availability_domain = "GPaJ:PHX-AD-2"
  compartment_id = "ocid1.compartment.oc1..aaaaaaaa5yqmecwmpytnntr6ktcrcgbon575ktozpuxbzzpvs67c2pziax4a"
  instance_image_id = "ocid1.image.oc1.phx.aaaaaaaagyogadwd4yoxr6262na3bbdt2xdm4cmloq2rylzplx4r77p4y2za"
  instance_shape = "VM.Standard2.2"
  is_lb_private = false
  load_balancer_id = ""
  mode = "PROD"
  network_compartment_id = "ocid1.compartment.oc1..aaaaaaaa7cpsku5d7xingyadmnchaeeg5ryqhnzo74md6rgw2ghtwvsic4uq"
  #opc_key = {public_key_openssh = "", private_key_pem = ""}
  #oracle_key = {public_key_openssh = "", private_key_pem = ""}
  region = var.region
  ssh_public_key = var.ssh_public_key
  subnet_id = "ocid1.subnet.oc1.phx.aaaaaaaaa6yhz37v7saxkvo3tvfrofkviw2cql4w4nddduvl5anelod7af2a"
  tenancy_id = var.tenancy_id
  tf_script_version = "22.2.1-220423002152"
  use_regional_subnet = false
  #volume_name = ""
  wls_14c_jdk_version = ""
  wls_admin_password_id = "ocid1.vaultsecret.oc1.phx.amaaaaaa3vsvjwaarqchhgbpblyqec5bdjjbjuykx5uqy5a3tji7qt6xpjdq"
  wls_admin_server_name = "MyAdminServer" # Must not be blank
  wls_admin_user = "weblogic"
  wls_domain_name = "mydomain"
  wls_server_startup_args = ""
  wls_subnet_id = "ocid1.subnet.oc1.phx.aaaaaaaarjblh6epjls6p3gxndlfkk6tae5ynfudi5g3hhpizofq5vr7ys2q"
  wls_vcn_cidr = "100.104.34.64/26"
  wls_version = "12.2.1.4"
  num_vm_instances = 2
  #compute_name_prefix = "nonjrf-instance"
  #service_name_prefix = "nonjrf-instance"
  resource_name_prefix = "nonjrf-instance"
  tags = {
    defined_tags = {}
    freeform_tags = module.system-tags.system_tag_value,
    dg_defined_tags = local.dg_defined_tags
  }
}