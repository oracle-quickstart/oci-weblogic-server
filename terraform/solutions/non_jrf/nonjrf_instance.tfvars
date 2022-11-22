# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

service_name = "nonjrf1"

### Public/private keys used on the instance
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDOOVKYC3NI6FQd63NTlEGhvGuk7+H69VCYXLC6JGIhaNQGb0DnEukcDVlONInrY0OFKD1NYFGPwuh+C65mgv3af+fCerUedWZwFKzuo+vNikQ9DOI7OIpCN3YHgZW43OmK51G2hfmi7QFjyNpJdUkw2GQb+IlP3lVAF4cQ5Pf1LZfn8oJVfDpAlZuIqR5MBDcoi/dNEO2a6o+Wm5tCOrkTuOLjOFqdWG0ugAsZyz/KwIZL9/ks4AGeM+RrJr8KA6Ck4XlSG62sMD4ph5GZSXQYsvodJjypC8XnAb6nW5LHEq6KYSooG/UBgzUVW0bsxFQoHO1nGtzZmn0KJd5Gu3rt xperiment"

### Set to true to create OCI IAM policies and dynamic groups required by the WebLogic for OCI stack
create_policies = true
generate_dg_tag = true

### Network vcn resource parameters required to create new vcn
network_compartment_id = "ocid1.compartment.oc1..aaaaaaaameasabragpehfwnzuxowgxyatkqguqghxynzigzyg7fse6nuatoq"
wls_vcn_name           = "nonjrf1"
wls_vcn_cidr           = "10.0.0.0/16"

### WebLogic credentials to login to the console
wls_admin_user        = "weblogic"
wls_admin_password_id = "ocid1.vaultsecret.oc1.iad.amaaaaaadogctgiawbobt2uytzu5m7b3waltjnwswsqutyjdzvbhvvzomqpa"

### WebLogic server compute instance parameters
instance_shape = "VM.Standard.E4.Flex"
wls_version    = "14.1.1.0"
wls_ocpu_count               = "1"
wls_node_count               = "2"
wls_availability_domain_name = "HiGv:US-ASHBURN-AD-2"
wls_subnet_cidr              = "10.0.2.0/24"

### Bastion parameters to create new bastion instance
is_bastion_instance_required = true
bastion_subnet_cidr          = "10.0.1.0/24"
bastion_instance_shape       = "VM.Standard2.1"

### Logging parameter to enable logging service integration for WebLogic instances
use_oci_logging = "true"
