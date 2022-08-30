# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_identity_fault_domains" "wls_fault_domains" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
}

data "template_file" "ad_names" {
  count    = length(data.oci_identity_availability_domains.ADs.availability_domains)
  template = (length(regexall("^.*Flex", var.instance_shape)) > 0 || (tonumber(lookup(data.oci_limits_limit_values.compute_shape_service_limits[count.index].limit_values[0], "value")) > 0)) ? lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index], "name") : ""
}

data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_id
}

data "oci_limits_limit_values" "compute_shape_service_limits" {
  count          = length(data.oci_identity_availability_domains.ADs.availability_domains)
  compartment_id = var.tenancy_id
  service_name   = "compute"

  availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index], "name")

  name = length(regexall("^.*Flex", var.instance_shape)) > 0 ? "" : format("%s-count", replace(var.instance_shape, ".", "-"))
}

data "template_file" "key_script" {
  template = file("${path.module}/templates/keys.tpl")

  vars = {
    pubKey = local.opc_key["public_key_openssh"]

    oracleKey    = local.oracle_key["public_key_openssh"]
    oraclePriKey = local.oracle_key["private_key_pem"]
  }
}

data "oci_core_shapes" "oci_shapes" {
  count               = length(data.oci_identity_availability_domains.ADs.availability_domains)
  compartment_id      = var.compartment_id
  image_id            = var.instance_image_id
  availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index], "name")
  filter {
    name   = "name"
    values = [var.instance_shape]
  }
}

data "oci_database_autonomous_database" "atp_db" {
  count                  = local.is_atp_db ? 1 : 0
  autonomous_database_id = var.jrf_parameters.atp_db_parameters.atp_db_id
}

data "template_file" "atp_nsg_id" {
  count    = local.is_atp_db ? 1 : 0
  template = length(data.oci_database_autonomous_database.atp_db[0].nsg_ids) > 0 ? data.oci_database_autonomous_database.atp_db[0].nsg_ids[0] : ""
}

data "oci_core_subnet" "wls_subnet" {
  count = var.wls_subnet_id == "" ? 0 : 1
  subnet_id = var.wls_subnet_id
}

data "oci_database_db_systems" "ocidb_db_systems" {
  count = local.is_ocidb_system_id_available? 1: 0
  compartment_id = var.jrf_parameters.oci_db_parameters.oci_db_compartment_id
  filter {
    name   = "id"
    values = [var.jrf_parameters.oci_db_parameters.oci_db_dbsystem_id]
  }
}

data "oci_database_database" "ocidb_database" {
  count = local.is_ocidb_system_id_available? 1: 0
  database_id = var.jrf_parameters.oci_db_parameters.oci_db_database_id
}

data "oci_database_db_home" "ocidb_db_home" {
  count = local.is_ocidb_system_id_available? 1: 0
  db_home_id = data.oci_database_database.ocidb_database[0].db_home_id
}

# Infra DB Private IP
# Case 1: RAC DB. Fetch the scan-ip list
data "oci_core_private_ip" "infra_db_scan_ip" {
  count = var.disable_infra_db_vcn_peering ? length(data.oci_database_db_systems.ocidb_db_systems[0].db_systems[0].scan_ip_ids) : 0
  private_ip_id = data.oci_database_db_systems.ocidb_db_systems[0].db_systems[0].scan_ip_ids[count.index]
}

data "oci_database_db_nodes" "ocidb_dbNode_list" {
  count = var.disable_infra_db_vcn_peering? 1: 0
  #Required
  compartment_id = var.compartment_id
  db_system_id = var.jrf_parameters.oci_db_parameters.oci_db_dbsystem_id
}

data "oci_database_db_node" "oci_db_node" {
  count = var.disable_infra_db_vcn_peering? local.infradb_node_count : 0
  db_node_id = data.oci_database_db_nodes.ocidb_dbNode_list[0].db_nodes[count.index].db_node_id
}

# For multi node DB
data "oci_core_vnic" "oci_db_vnic" {
  count = var.disable_infra_db_vcn_peering && local.infradb_node_count > 1 ? local.infradb_node_count : 0
  vnic_id = data.oci_database_db_node.oci_db_node[count.index].vnic_id
}

# For single Node DB
data "oci_core_vnic" "oci_db_vnic_single_node" {
  count = var.disable_infra_db_vcn_peering && local.infradb_node_count == 1 ? 1 : 0
  vnic_id = data.oci_database_db_node.oci_db_node[0].vnic_id
}

