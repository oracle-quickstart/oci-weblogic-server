# Copyright (c) 2023, 2026, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_identity_fault_domains" "wls_fault_domains" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
}

locals {
  ad_names = compact([
    for i in range(var.num_ads) :
    (length(regexall("^.*Flex", var.instance_shape.instanceShape)) > 0 || length(regexall("^BM.*", var.instance_shape.instanceShape)) > 0 || (tonumber(lookup(data.oci_limits_limit_values.compute_shape_service_limits[i].limit_values[0], "value")) > 0)) ? lookup(data.oci_identity_availability_domains.ADs.availability_domains[i], "name") : ""
  ])
}

data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_id
}

data "oci_limits_limit_values" "compute_shape_service_limits" {
  count          = var.num_ads
  compartment_id = var.tenancy_id
  service_name   = "compute"

  availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[count.index], "name")
  name                = length(regexall("^.*Flex", var.instance_shape.instanceShape)) > 0 || length(regexall("^BM.*", var.instance_shape.instanceShape)) > 0 ? "" : format("%s-count", replace(var.instance_shape.instanceShape, ".", "-"))
}

locals {
  key_script = templatefile("${path.module}/templates/keys.tpl", {
    pubKey = local.opc_key["public_key_openssh"]

    oracleKey    = local.oracle_key["public_key_openssh"]
    oraclePriKey = local.oracle_key["private_key_pem"]
  })
}

data "oci_database_autonomous_database" "atp_db" {
  count                  = local.is_atp_db ? 1 : 0
  autonomous_database_id = var.jrf_parameters.atp_db_parameters.atp_db_id
}

data "oci_core_subnet" "wls_subnet" {
  count     = var.wls_subnet_id == "" ? 0 : 1
  subnet_id = var.wls_subnet_id
}

data "oci_database_db_systems" "ocidb_db_systems" {
  count          = local.is_ocidb_system_id_available ? 1 : 0
  compartment_id = var.jrf_parameters.oci_db_parameters.oci_db_compartment_id
  filter {
    name   = "id"
    values = [var.jrf_parameters.oci_db_parameters.oci_db_dbsystem_id]
  }
}

data "oci_database_database" "ocidb_database" {
  count       = local.is_ocidb_system_id_available ? 1 : 0
  database_id = var.jrf_parameters.oci_db_parameters.oci_db_database_id
}

data "oci_database_db_home" "ocidb_db_home" {
  count      = local.is_ocidb_system_id_available ? 1 : 0
  db_home_id = data.oci_database_database.ocidb_database[0].db_home_id
}
