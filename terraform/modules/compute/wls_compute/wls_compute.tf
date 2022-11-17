# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

module "compute-keygen" {
  source = "../keygen"
}

module "wls-instances" {

  source = "../instance"

  instance_params = { for x in range(var.num_vm_instances) : "${local.host_label}-${x}" => {

    availability_domain = var.use_regional_subnet ? local.ad_names[(x + local.admin_ad_index) % length(local.ad_names)] : var.availability_domain

    compartment_id = var.compartment_id
    display_name   = "${local.host_label}-${x}"
    shape          = var.instance_shape

    defined_tags  = local.defined_tags
    freeform_tags = var.tags.freeform_tags

    subnet_id         = var.subnet_id
    vnic_display_name = "primaryvnic"
    assign_public_ip  = var.assign_public_ip
    hostname_label    = "${local.host_label}-${x}"
    compute_nsg_ids   = length(var.compute_nsg_ids) != 0 ? x == 0 ? var.compute_nsg_ids : [element(var.compute_nsg_ids, 1)] : []

    source_type = "image"
    source_id   = var.instance_image_id

    metadata = {

      service_name                       = var.resource_name_prefix
      service_name_prefix                = var.resource_name_prefix
      tf_script_version                  = var.tf_script_version
      ssh_authorized_keys                = var.ssh_public_key
      wls_admin_user                     = var.wls_admin_user
      wls_admin_password_ocid            = var.wls_admin_password_id
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
      wls_server_startup_args            = var.wls_server_startup_args
      total_vm_count                     = var.num_vm_instances
      assign_public_ip                   = var.assign_public_ip
      wls_existing_vcn_id                = var.wls_existing_vcn_id
      mount_vcn_id                       = var.mount_vcn_id
      wls_subnet_ocid                    = var.subnet_id
      wls_vcn_cidr                       = var.wls_vcn_cidr
      network_compartment_id             = var.network_compartment_id
      wls_subnet_cidr                    = local.wls_subnet_cidr
      wls_edition                        = var.wls_edition
      is_bastion_instance_required       = var.is_bastion_instance_required

      user_data            = data.template_cloudinit_config.config.rendered
      mode                 = var.mode
      wls_version          = var.wls_version
      wls_14c_jdk_version  = var.wls_14c_jdk_version
      fmiddleware_zip      = var.wls_version_to_fmw_map[var.wls_version]
      jdk_zip              = var.wls_version == "14.1.1.0" ? var.wls_14c_to_jdk_map[var.wls_14c_jdk_version] : var.wls_version_to_jdk_map[var.wls_version]
      vmscripts_path       = var.vmscripts_path
      log_level            = var.log_level
      mw_vol_mount_point   = lookup(var.volume_map[0], "volume_mount_point")
      mw_vol_device        = lookup(var.volume_map[0], "device")
      data_vol_mount_point = lookup(var.volume_map[1], "volume_mount_point")
      data_vol_device      = lookup(var.volume_map[1], "device")

      deploy_sample_app                  = var.deploy_sample_app
      domain_dir                         = var.domain_dir
      logs_dir                           = var.logs_dir
      status_check_timeout_duration_secs = var.status_check_timeout_duration_secs
      allow_manual_domain_extension      = var.allow_manual_domain_extension
      load_balancer_id                   = var.load_balancer_id
      add_loadbalancer                   = var.add_loadbalancer
      is_lb_private                      = var.is_lb_private

      is_idcs_selected                    = var.is_idcs_selected
      idcs_host                           = var.idcs_host
      idcs_port                           = var.idcs_port
      is_idcs_internal                    = "false"
      is_idcs_untrusted                   = false
      idcs_ip                             = ""
      idcs_tenant                         = var.idcs_tenant
      idcs_client_id                      = var.idcs_client_id
      idcs_client_secret_ocid             = var.idcs_client_secret_id
      idcs_app_prefix                     = var.idcs_app_prefix
      idcs_cloudgate_port                 = var.idcs_cloudgate_port
      idcs_artifacts_file                 = var.idcs_artifacts_file
      idcs_conf_app_info_file             = var.idcs_conf_app_info_file
      idcs_ent_app_info_file              = var.idcs_ent_app_info_file
      idcs_cloudgate_info_file            = var.idcs_cloudgate_info_file
      idcs_cloudgate_config_file          = var.idcs_cloudgate_config_file
      lbip                                = var.lbip
      idcs_cloudgate_docker_image_tar     = var.idcs_cloudgate_docker_image_tar
      idcs_cloudgate_docker_image_version = var.idcs_cloudgate_docker_image_version
      idcs_cloudgate_docker_image_name    = var.idcs_cloudgate_docker_image_name

      # Common JRF DB parameters
      apply_JRF                   = local.apply_JRF
      db_name                     = local.is_atp_db ? data.oci_database_autonomous_database.atp_db[0].db_name : local.is_oci_db ? try(data.oci_database_database.ocidb_database[0].db_name, "") : ""
      db_user                     = var.jrf_parameters.db_user
      db_password_ocid            = var.jrf_parameters.db_password_id
      db_existing_vcn_add_seclist = var.db_existing_vcn_add_seclist

      rcu_component_list = lookup(var.wls_version_to_rcu_component_list_map, var.wls_version, "")

      # OCI DB parameters for JRF
      db_is_oci_db                 = local.is_oci_db
      db_connect_string            = var.jrf_parameters.oci_db_parameters.oci_db_connection_string
      db_hostname_prefix           = local.is_oci_db ? try(lookup(data.oci_database_db_systems.ocidb_db_systems[0].db_systems[0], "hostname"), "") : ""
      db_host_domain               = local.is_oci_db ? try(lookup(data.oci_database_db_systems.ocidb_db_systems[0].db_systems[0], "domain"), "") : ""
      db_shape                     = local.is_oci_db ? try(lookup(data.oci_database_db_systems.ocidb_db_systems[0].db_systems[0], "shape"), "") : ""
      db_version                   = local.is_oci_db ? try(data.oci_database_db_home.ocidb_db_home[0].db_version, "") : ""
      db_unique_name               = local.is_oci_db ? try(data.oci_database_database.ocidb_database[0].db_unique_name, "") : ""
      pdb_name                     = var.jrf_parameters.oci_db_parameters.oci_db_pdb_service_name
      db_node_count                = local.is_oci_db ? try(lookup(data.oci_database_db_systems.ocidb_db_systems[0].db_systems[0], "node_count"), "") : ""
      db_port                      = var.jrf_parameters.oci_db_parameters.oci_db_port
      db_storage_management        = local.is_oci_db ? local.db_storage_management : ""
      db_subnet_id                 = local.is_oci_db ? try(lookup(data.oci_database_db_systems.ocidb_db_systems[0].db_systems[0], "subnet_id"), "") : ""
      ocidb_network_compartment_id = var.jrf_parameters.oci_db_parameters.oci_db_network_compartment_id
      ocidb_existing_vcn_id        = var.jrf_parameters.oci_db_parameters.oci_db_existing_vcn_id

      # These two are used only to make sure WLS compute is created after VCN peering for DNS resolution and
      # LPG routing are created. These are not used in the provisioning scripts
      wls_vcn_peering_dns_resolver_id           = var.wls_vcn_peering_dns_resolver_id
      wls_vcn_peering_route_table_attachment_id = var.wls_vcn_peering_route_table_attachment_id

      # Optional Peering TODO: remove these two when code from image related to this is removed as well
      db_scan_ip_list     = ""
      db_host_private_ips = ""

      # ATP parameters for JRF
      is_atp_db             = local.is_atp_db
      atp_db_id             = var.jrf_parameters.atp_db_parameters.atp_db_id
      atp_db_level          = var.jrf_parameters.atp_db_parameters.atp_db_level
      is_atp_dedicated      = local.is_atp_db ? lookup(data.oci_database_autonomous_database.atp_db[0], "is_dedicated") : false
      atp_private_end_point = element(coalescelist(data.oci_database_autonomous_database.atp_db.*.private_endpoint, [""]), 0)
      atp_nsg_id            = local.is_atp_db ? data.template_file.atp_nsg_id[0].rendered : ""

      # TODO: These variables are hardcoded to allow creating instances without app db. Remove them once app db code is removed from image
      is_atp_app_db       = "false"
      appdb_user          = ""
      appdb_password_ocid = ""

      log_group_id    = var.log_group_id
      use_oci_logging = var.use_oci_logging

      mount_ip    = var.mount_ip
      mount_path  = var.mount_path
      export_path = var.export_path
      add_fss     = var.add_fss

      use_apm_service                = var.use_apm_service
      apm_domain_compartment_id      = var.apm_domain_compartment_id
      apm_domain_id                  = var.apm_domain_id
      apm_private_data_key_name      = var.apm_private_data_key_name
      apm_agent_installer_path       = var.apm_agent_installer_path
      apm_agent_path                 = var.apm_agent_path
      use_autoscaling                = var.use_autoscaling ? "Metric" : "None"
      stack_compartment_id           = var.compartment_id
      scalein_notification_topic_id  = var.use_autoscaling ? var.scalein_notification_topic_id : ""
      scaleout_notification_topic_id = var.use_autoscaling ? var.scaleout_notification_topic_id : ""
      ocir_url                       = var.use_autoscaling ? var.ocir_url : ""
      ocir_user                      = var.use_autoscaling ? var.ocir_user : ""
      ocir_auth_token_id             = var.use_autoscaling ? var.ocir_auth_token_id : ""
      fn_repo_path                   = var.use_autoscaling ? var.fn_repo_path : ""
      fn_application_id              = var.use_autoscaling ? var.fn_application_id : ""
      is_ucm_image                   = var.is_ucm_image
      #Metadata tags are in the form:
      #{tagkey1=tagval1, tagkey2=tagval2, ...}
      defined_tags       = join(",", [for key, value in local.defined_tags : "${key}=${value}"])
      freeform_tags      = join(",", [for key, value in var.tags.freeform_tags : "${key}=${value}"])
      defined_system_tag = join(",", [for key, value in var.tags.defined_tags : "${key}=${value}"])
    }

    are_legacy_imds_endpoints_disabled = var.disable_legacy_metadata_endpoint
    fault_domain                       = (length(local.ad_names) == 1 || !var.use_regional_subnet) ? lookup(data.oci_identity_fault_domains.wls_fault_domains.fault_domains[(x + 1) % local.num_fault_domains], "name") : ""

    provisioning_timeout_mins = var.provisioning_timeout_mins

    }
  }
}

