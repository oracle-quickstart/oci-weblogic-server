# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

output "nsg_id" {
  description = "OCID of the created nsg"
  value       = tolist(oci_core_network_security_group.nsg.*.id)
}