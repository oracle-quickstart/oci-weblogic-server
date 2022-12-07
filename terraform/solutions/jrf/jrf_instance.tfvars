# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

service_name = "jrf1"

### Public/private keys used on the instance
ssh_public_key = "<ssh_public_key>"

### Set to true to create OCI IAM policies and dynamic groups required by the WebLogic for OCI stack
create_policies = true
generate_dg_tag = true

### Existing Network VCN resource parameters
network_compartment_id = "ocid1.compartment.xxxxxxxxxxxxxx"
wls_existing_vcn_id	= "ocid1.vcn.xxxxxxxxxxxxxxx"

### WebLogic credentials to login to the console
wls_admin_user = "weblogic"
wls_admin_password_id = "ocid1.vaultsecret.xxxxxxxxxxxxxxx"

### WebLogic server compute instance parameters
instance_shape = "VM.Standard.E4.Flex"
wls_version = "12.2.1.4"
wls_ocpu_count = 1
wls_node_count = 2
wls_availability_domain_name = "HiGv:US-ASHBURN-AD-2"
wls_subnet_id = "ocid1.subnet.xxxxxxxxxxxxxxx"

### Bastion parameters to create new bastion instance
is_bastion_instance_required = true
bastion_subnet_id = "ocid1.subnet.xxxxxxxxxxxxxxx"
bastion_instance_shape = "VM.Standard2.1"
