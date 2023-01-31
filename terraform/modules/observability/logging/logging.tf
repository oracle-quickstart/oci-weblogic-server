# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  log_paths1 = [
    format("/u01/data/domains/%s_domain/servers/%s_adminserver/logs/%s_adminserver.log*", var.service_prefix_name, var.service_prefix_name, var.service_prefix_name),
    format("/u01/data/domains/%s_domain/nodemanager/nodemanager.log*", var.service_prefix_name),
    format("/u01/data/domains/%s_domain/servers/%s_adminserver/logs/%s_domain.log*", var.service_prefix_name, var.service_prefix_name, var.service_prefix_name)
  ]
  #The following expression generates a list of paths for servers from 1 to 30
  log_paths2 = [
    for i in range(1, 31) : format("/u01/data/domains/%s_domain/servers/%s_server_%s/logs/%s_server_%s.log*", var.service_prefix_name, var.service_prefix_name, i, var.service_prefix_name, i)
  ]
  log_paths = concat(local.log_paths1, local.log_paths2)
}

resource "oci_logging_log" "wlsc_log" {
  #Required
  display_name = format("%s_log", var.service_prefix_name)
  log_group_id = var.log_group_id
  log_type     = var.log_log_type
  is_enabled   = var.use_oci_logging

  defined_tags  = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags

  lifecycle {
    ignore_changes = all
  }
}

resource "oci_logging_unified_agent_configuration" "wlsc_unified_agent_configuration" {
  #Required
  compartment_id = var.compartment_id
  is_enabled     = var.use_oci_logging
  description    = "WLS-OCI Stack Log Agent Configuration"
  display_name   = format("%s_agent_config", var.service_prefix_name)

  defined_tags  = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags
  service_configuration {
    #Required
    configuration_type = var.unified_agent_configuration_service_configuration_configuration_type

    destination {
      #Required
      log_object_id = oci_logging_log.wlsc_log.id
    }
    sources {
      #Required
      source_type = var.unified_agent_configuration_service_configuration_source_type
      paths       = local.log_paths
      name        = format("%s_logs", var.service_prefix_name)
      parser {
        parser_type = var.unified_agent_configuration_service_configuration_parser_type
      }
    }
  }

  group_association {

    #Optional
    group_list = var.create_policies ? [var.oci_managed_instances_principal_group] : [var.dynamic_group_id]
  }

  lifecycle {
    ignore_changes = all
  }
}