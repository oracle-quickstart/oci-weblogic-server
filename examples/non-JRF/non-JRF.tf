
variable "ssh_public_key" {
  type        = string
  description = "public key for ssh access to WebLogic instances"
}

variable "tenancy_ocid" {}

variable "region" {
  default = "us-phoenix-1"
}

module "compute-keygen" {
  source = "../../modules/keygen"
}

module "non-JRF" {
  source = "../../modules/compute/wls_compute"
  add_loadbalancer = false
  assign_public_ip = false
  availability_domain = "GPaJ:PHX-AD-2"
  compartment_ocid = "ocid1.compartment.oc1..aaaaaaaa5yqmecwmpytnntr6ktcrcgbon575ktozpuxbzzpvs67c2pziax4a"
  instance_image_ocid = "ocid1.image.oc1.phx.aaaaaaaagyogadwd4yoxr6262na3bbdt2xdm4cmloq2rylzplx4r77p4y2za"
  instance_shape = "VM.Standard2.2"
  is_lb_private = false
  load_balancer_id = ""
  mode = "PROD"
  network_compartment_id = "ocid1.compartment.oc1..aaaaaaaa7cpsku5d7xingyadmnchaeeg5ryqhnzo74md6rgw2ghtwvsic4uq"
  #opc_key = {public_key_openssh = "", private_key_pem = ""}
  #oracle_key = {public_key_openssh = "", private_key_pem = ""}
  oracle_key = module.compute-keygen.OraclePrivateKey
  opc_key = module.compute-keygen.OPCPrivateKey
  region = var.region
  ssh_public_key = var.ssh_public_key
  subnet_ocid = "ocid1.subnet.oc1.phx.aaaaaaaaa6yhz37v7saxkvo3tvfrofkviw2cql4w4nddduvl5anelod7af2a"
  tenancy_ocid = var.tenancy_ocid
  tf_script_version = "22.2.1-220423002152"
  use_regional_subnet = false
  volume_name = ""
  wls_14c_jdk_version = ""
  wls_admin_password = "ocid1.vaultsecret.oc1.phx.amaaaaaa3vsvjwaarqchhgbpblyqec5bdjjbjuykx5uqy5a3tji7qt6xpjdq"
  wls_admin_server_name = "MyAdminServer" # Must not be blank
  wls_admin_user = "weblogic"
  wls_domain_name = "mydomain"
  wls_server_startup_args = ""
  wls_subnet_id = "ocid1.subnet.oc1.phx.aaaaaaaarjblh6epjls6p3gxndlfkk6tae5ynfudi5g3hhpizofq5vr7ys2q"
  wls_vcn_cidr = ""
  wls_version = "12.2.1.4"
  numVMInstances = "2"
  compute_name_prefix = "nonjrf-instance"
  service_name_prefix = "nonjrf-instance"
}