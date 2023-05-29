# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.


// Resolves the private IP of the customer's private endpoint to a NAT IP. Used as the host address in the "remote-exec" resource
data "oci_resourcemanager_private_endpoint_reachable_ip" "private_endpoint_reachable_ips" {
  count               = var.is_rms_private_endpoint_required ? var.num_vm_instances : 0
  private_endpoint_id = var.rms_private_endpoint_id
  private_ip          = var.host_ips[count.index]
}
