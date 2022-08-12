output "wlsc_oci_policy_id" {
  value       = oci_identity_policy.wlsc_oci_policy.id
  description = "The OCID of the policy created for the WebLogic for OCI instance"
}

output "oci_managed_instances_principal_group" {
  value       = oci_identity_dynamic_group.wlsc_instance_principal_group.id
  description = "The OCID of the dynamic group created for the VMs of the WebLogic for OCI instance"
}