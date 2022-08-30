# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

output "log_id" {
  #value = (var.use_oci_logging ? element(concat(oci_logging_log.wlsc_log.*.id, tolist([""])),0) : "")
  value = oci_logging_log.wlsc_log.id
}

output "agent_config_id" {
  #value = (var.use_oci_logging ? element(concat(oci_logging_unified_agent_configuration.wlsc_unified_agent_configuration.*.id, tolist([""])),0) : "")
  value = oci_logging_unified_agent_configuration.wlsc_unified_agent_configuration.id
}