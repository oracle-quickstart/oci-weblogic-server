
locals {
  system_defined_dg_tag_value = format("%s-%s", var.service_name, substr(random_uuid.uuid_1.result, 0, 8))
  system_tag_value            = { "wlsoci-${var.service_name}-system-tag" : local.system_defined_dg_tag_value }
}

resource "random_uuid" "uuid_1" {
}

resource "oci_identity_tag_namespace" "wlsoci_tag_namespace" {
  count = var.create_dg_tags ? 1 : 0

  compartment_id = var.compartment_id
  description    = "WebLogic for OCI tag namespace"
  name           = format("wlsoci-${var.service_name}-%s-tags", substr(random_uuid.uuid_1.result, 0, 8))
  is_retired     = false
}


resource "oci_identity_tag" "wlsoci_dynamic_group_tag_key" {
  count = var.create_dg_tags ? 1 : 0

  description      = "WebLogic for OCI tag key for dynamic group"
  name             = "wlsoci-${var.service_name}-dg-tag"
  tag_namespace_id = oci_identity_tag_namespace.wlsoci_tag_namespace[0].id
  is_retired       = false

  dynamic "validator" {
    for_each = var.is_system_tag ? [random_uuid.uuid_1.result] : []

    content {
      validator_type = "ENUM"
      values         = [local.system_defined_dg_tag_value]
    }
  }
}

resource "time_sleep" "tag_creation_delay" {
  count = var.create_dg_tags ? 1 : 0

  create_duration = "180s"
  triggers = {
    dg_tag_key_name = var.create_dg_tags ? oci_identity_tag.wlsoci_dynamic_group_tag_key[0].name : ""
  }
}
