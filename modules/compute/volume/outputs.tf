# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

output "data_volume_ids" {
  value       = [for b in oci_core_volume.these : b.id]
  description = "The OCID of each volume"
}