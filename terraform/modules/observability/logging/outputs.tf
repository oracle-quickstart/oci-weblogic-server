# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

output "log_id" {
  value = oci_logging_log.wlsc_log.id
}

output "agent_config_id" {
  value = oci_logging_unified_agent_configuration.wlsc_unified_agent_configuration.id
}