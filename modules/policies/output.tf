output "wlsc_oci_policy_id" {
  value       = var.create_policies ? length(oci_identity_policy.wlsc_oci_policy) > 0 ? element(concat(oci_identity_policy.wlsc_oci_policy[0].*.id, tolist([""])), 0) : "" : ""
  description = "The OCID of the policy created for the WebLogic for OCI instance"
}

output "oci_managed_instances_principal_group" {
  value       = var.create_policies ? element(concat(oci_identity_dynamic_group.wlsc_instance_principal_group.*.id, tolist([""])), 0) : ""
  description = "The OCID of the dynamic group created for the VMs of the WebLogic for OCI instance"
}