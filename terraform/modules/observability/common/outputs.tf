# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

output "log_group_id" {
  value = oci_logging_log_group.wlsc_log_group.id
}