# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

service_name = "nonjrf1"

### Public/private keys used on the instance
ssh_public_key = "<ssh_public_key>"

### Set to true to create OCI IAM policies and dynamic groups required by the WebLogic for OCI stack
create_policies = true
generate_dg_tag = true

### Network vcn resource parameters required to create new vcn
network_compartment_id = "ocid1.compartment.xxxxxxxxxxxxxx"
wls_vcn_name           = "nonjrf1"
wls_vcn_cidr           = "10.0.0.0/16"

### WebLogic credentials to login to the console
wls_admin_user        = "weblogic"
wls_admin_password_id = "ocid1.vaultsecret.xxxxxxxxxxxxxxx"

### WebLogic server compute instance parameters
instance_shape = "VM.Standard.E4.Flex"
wls_version    = "14.1.1.0"
wls_ocpu_count               = 1
wls_node_count               = 2
wls_availability_domain_name = "<availability_domain_name>"
wls_subnet_cidr              = "10.0.2.0/24"

### Bastion parameters to create new bastion instance
is_bastion_instance_required = true
bastion_subnet_cidr          = "10.0.1.0/24"
bastion_instance_shape       = "VM.Standard2.1"

### Logging parameter to enable logging service integration for WebLogic instances
use_oci_logging = true
