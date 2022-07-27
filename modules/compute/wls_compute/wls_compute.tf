module "wls-instances" {

source = "../instance"

instance_params = { for x in range(var.numVMInstances) : "${local.host_label}-${x}" => {

  availability_domain = var.use_regional_subnet ? local.ad_names[x % length(local.ad_names)] : var.availability_domain

  compartment_id = var.compartment_ocid
  display_name   = "${local.host_label}-${x}"
  shape          = var.instance_shape

  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags

  subnet_id        = var.subnet_ocid
  vnic_display_name     = "primaryvnic"
  assign_public_ip = var.assign_public_ip
  hostname_label   = "${local.host_label}-${x}"
  #nsg_ids = var.nsg_ids
  nsg_ids = []

  ocpus = length(regexall("^.*Flex", var.instance_shape))==0 ? lookup(data.oci_core_shapes.oci_shapes[x % length(local.ad_names)].shapes[0],"ocpus") : var.wls_ocpu_count

  source_type = "image"
  source_id   = var.instance_image_ocid

  metadata = {

    service_name                       = var.compute_name_prefix
    service_name_prefix                = var.service_name_prefix
    tf_script_version                  = var.tf_script_version
    ssh_authorized_keys                = var.ssh_public_key
    wls_admin_user                     = var.wls_admin_user
    wls_admin_password_ocid            = var.wls_admin_password
    wls_domain_name                    = var.wls_domain_name
    is_admin_instance                  = x == 0 ? true : false
    wls_ext_admin_port                 = var.wls_extern_admin_port
    wls_secured_ext_admin_port         = var.wls_extern_ssl_admin_port
    wls_admin_port                     = var.wls_admin_port
    wls_admin_ssl_port                 = var.wls_admin_ssl_port
    wls_nm_port                        = var.wls_nm_port
    host_index                         = x
    wls_admin_host                     = "${local.host_label}-0"
    wls_admin_server_wait_timeout_mins = var.wls_admin_server_wait_timeout_mins
    wls_ms_ssl_port                    = var.wls_ms_ssl_port
    wls_ms_port                        = var.wls_ms_port
    wls_ms_extern_port                 = var.wls_ms_extern_port
    wls_ms_extern_ssl_port             = var.wls_ms_extern_ssl_port
    wls_ms_server_name                 = var.wls_ms_server_name
    wls_admin_server_name              = var.wls_admin_server_name
    wls_cluster_name                   = var.wls_cluster_name
    wls_cluster_mc_port                = var.wls_cluster_mc_port
    wls_machine_name                   = var.wls_machine_name
    total_vm_count                     = var.numVMInstances
    assign_public_ip                   = var.assign_public_ip
    wls_existing_vcn_id                = var.wls_existing_vcn_id
    wls_subnet_ocid                    = var.subnet_ocid
    variant                            = var.patching_tool_key
    wls_edition                        = var.wls_edition
    patching_actions                   = var.supported_patching_actions


    user_data                          = data.template_cloudinit_config.config.rendered
    mode                               = var.mode
    wls_version                        = var.wls_version
    wls_14c_jdk_version                = var.wls_14c_jdk_version
    fmiddleware_zip                    = var.wls_version_to_fmw_map[var.wls_version]
    jdk_zip                            = var.wls_version=="14.1.1.0"?var.wls_14c_to_jdk_map[var.wls_14c_jdk_version]:var.wls_version_to_jdk_map[var.wls_version]
    vmscripts_path                     = var.vmscripts_path
    log_level                          = var.log_level
    mw_vol_mount_point                 = lookup(var.volume_map[0], "volume_mount_point")
    mw_vol_device                      = lookup(var.volume_map[0], "device")
    data_vol_mount_point               = lookup(var.volume_map[1], "volume_mount_point")
    data_vol_device                    = lookup(var.volume_map[1], "device")

    deploy_sample_app                  = var.deploy_sample_app
    domain_dir                         = var.domain_dir
    logs_dir                           = var.logs_dir
    #apply_JRF                          = local.is_apply_JRF
    status_check_timeout_duration_secs = var.status_check_timeout_duration_secs
    allow_manual_domain_extension      = var.allow_manual_domain_extension
    load_balancer_id                   = var.load_balancer_id
    add_loadbalancer                   = var.add_loadbalancer
    is_lb_private                      = var.is_lb_private

    # TODO (robesanc): These variables are hardcoded to allow non-JRF scenarios for now
    is_atp_db = "false"
    appdb_password_ocid = ""
    apply_JRF = "false"
    is_atp_app_db = "false"

  }

  are_legacy_imds_endpoints_disabled = var.disable_legacy_metadata_endpoint
  fault_domain = (length(local.ad_names) == 1 || ! var.use_regional_subnet) ? lookup(data.oci_identity_fault_domains.wls_fault_domains.fault_domains[(x + 1) % local.num_fault_domains], "name") : ""

  provisioning_timeout_mins = var.provisioning_timeout_mins

  }
}
}

