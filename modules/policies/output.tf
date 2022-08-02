output "wlsc-oci-policy-id"{
  value = var.create_policies ? length(oci_identity_policy.wlsc-oci-policy) > 0 ? element(concat(oci_identity_policy.wlsc-oci-policy[0].*.id, tolist([""])),0) : "" : ""
}

output "oci_managed_instances_principal_group" {
  value = var.create_policies  ? element(concat(oci_identity_dynamic_group.wlsc_instance_principal_group.*.id, tolist([""])),0) :  ""
}