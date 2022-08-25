# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

# Output of the subnet creation
output "subnet_id" {
  description = "OCID of created subnet. "
  value       = oci_core_subnet.wls-subnet.id
}
