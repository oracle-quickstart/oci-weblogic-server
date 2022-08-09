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