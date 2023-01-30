# Variables

The variables you define for the stack determine the resources that will be provisioned. Some variables are optional, but
some are required. This document lists the different components for which you can specify variables to change the resources
created with the stack, and the files that contain those variables.

*NOTE:* There are some variables that have a comment like `Variable used in UI only`. You should not set values for those
variables.

## OCI and Service

These variables are required because they indicate, among other things:
  - The tenancy and region where the stack and its resources are created
  - The user creating the resources
  - The compartment where the resources are created

For example:
```terraform
user_id          = "ocid1.user.xxxxxxxxxxxxxx"
fingerprint      = "<fingerprint>"
private_key_path = "~/.oci/oci_api_key_prod.pem"

tenancy_ocid     = "ocid1.tenancy.xxxxxxxxxxxxxxxxxx"
region           = "us-ashburn-1"
compartment_ocid = "ocid1.compartment.xxxxxxxxxxxxxxxx"
service_name     = "test"
```
Review the [variables.tf](./terraform/variables.tf) file for more details.

## Network Variables

You can create a new VCN for your stack, or you can use an existing VCN, but create new subnets, or you can use existing
subnets for your stack. If you use existing subnets, you can use security lists to control network traffic between resources
of the stack, or you can use network security groups (NSG). To use one of these options, you use variables from the
[network_variables.tf](./terraform/network_variables.tf) file.

If you want to create a new VCN, you can set these variables:
```terraform
# Specify a compartment different from the stack compartment to create all network resources
network_compartment_id   = "ocid1.compartment.xxxxxxxxxxxxxx"
wls_vcn_name             = "myvcn"
#CIDR of the new VCN and subnets for different resources
wls_vcn_cidr             = "10.0.0.0/16"
wls_subnet_cidr          = "10.0.2.0/24"
#Required if you add a load balancer
lb_subnet_1_cidr         = "10.0.3.0/24"
#Required if you add a file system  and new mount target
mount_target_subnet_cidr = "10.0.4.0/24"
#Required if you add a bastion
bastion_subnet_cidr          = "10.0.1.0/24"
```

If you want to use an existing VCN and subnets, you can set these variables:
```terraform
# Specify a compartment different from the stack compartment to create all network resources
network_compartment_id   = "ocid1.compartment.xxxxxxxxxxxxxx"
# Use this if the existng subnets to use are AD-specific
#use_regional_subnet = false
wls_existing_vcn_id = "ocid1.vcn.xxxxxxxxxxxxxxx"
wls_subnet_id = "ocid1.subnet.xxxxxxxxxxxxxxx"
#Required if you add a load balancer
lb_subnet_1_id = "ocid1.subnet.xxxxxxxxxxxxxxx"
#Required only if using AD-specific subnets
#lb_subnet_2_id = "ocid1.subnet.xxxxxxxxxxxxxxx"
#Required if you add a file system  and new mount target
mount_target_subnet_id = "ocid1.subnet.xxxxxxxxxxxxxxx"
#Required if you add a bastion
bastion_subnet_id = "ocid1.subnet.xxxxxxxxxxxxxxx"
```

## WebLogic Domain

The variables that determine the way your WebLogic domain will be created are in the [weblogic_variables.tf](./terraform/weblogic_variables.tf)
file.

For example, to create a WebLogic 14c domain with JDK 11 and two managed servers, you can specify the following:
```terraform
wls_admin_user        = "weblogic"
wls_admin_password_id = "ocid1.vaultsecret.xxxxxxxxxxxxxxx"
wls_version           = "14.1.1.0"
wls_14c_jdk_version   = "jdk11"
wls_node_count        = 2
```

If you want to create a JRF domain, you need to specify variables for a database, either ATP or OCI DB. See the [Database](#database)
section for more details.

## Database

If you want to create a WebLogic JRF domain, you must specify the details of a database. The supported databases are ATP
and OCI DB.

If you want to use an ATP database to create a JRF domain you can use the following variables:
```terraform
atp_db_id             = "ocid1.autonomousdatabase.oc1.xxxxxxxxxxxxxxx"
atp_db_password_id    = "ocid1.vaultsecret.oc1.xxxxxxxxxxxxxxx"
atp_db_compartment_id = "ocid1.compartment.oc1..xxxxxxxxxxxxxxx"
atp_db_level          = "tp"

# In case your ATP DB uses private endpoint
# atp_db_existing_vcn_id = "ocid1.vcn.oc1.atp_db_level"

# In case VCN peering is needed
#db_vcn_lpg_id = "ocid1.localpeeringgateway.oc1.atp_db_level"
```
If you want to use an OCi DB database to create a JRF domain you can use the following variables:
```terraform
oci_db_compartment_id         = "ocid1.compartment.xxxxxxxxxxxxxxx"
oci_db_dbsystem_id            = "ocid1.dbsystem.xxxxxxxxxxxxxxx"
oci_db_database_id            = "ocid1.database.xxxxxxxxxxxxxxx"
oci_db_pdb_service_name	      = "<oci_db_pdb_service_name>"
oci_db_user                   = "SYS"
oci_db_password_id            = "ocid1.vaultsecret.xxxxxxxxxxxxxxx"
oci_db_network_compartment_id = "ocid1.compartment.xxxxxxxxxxxxxxx"
oci_db_existing_vcn_id        = "ocid1.vcn.xxxxxxxxxxxxxxxa"
db_existing_vcn_add_secrule   = true

# In case VCN peering is needed
#db_vcn_lpg_id = "ocid1.localpeeringgateway.oc1.atp_db_level"
```
Review the [db_variables.tf](./terraform/db_variables.tf) file for more details.

## WebLogic Compute Instance

To specify shape and OCPUs (for flex shapes) for the WebLogic VMs, you can set variables from the [variables.tf](./terraform/variables.tf) file.

For example:
```terraform
instance_shape = "VM.Standard.E4.Flex"
wls_ocpu_count = 1
# By default, the first WebLogic VM is placed in the first AD, but you can change that behavior with this variable
wls_availability_domain_name = "<availability domain name>"
```

## Bastion

To customize the bastion instance creation (which is enabled by default), use an existing bastion, or disable the use of
a bastion instance, you can set the variables in the [bastion_variables.tf](./terraform/bastion_variables.tf) file.

For example, to create a new bastion with a reserved public IP, with a VM shape different from the default, set these variables:
```terraform
is_bastion_instance_required       = true
bastion_instance_shape             = "VM.Standard2.1"
is_bastion_with_reserved_public_ip = true
```

## Load Balancer Variables

To add a load balancer to distribute traffic to the servers of the WebLogic domain, use the variables in the
[network_variables.tf](./terraform/network_variables.tf) file.

For example, to add a new load balancer to your stack, you can use these variables:
```terraform
add_load_balancer = true
# Use this if you are creating new subnets
lb_subnet_1_cidr  = "10.0.3.0/24"
# Use this if you are using existing subnets
#lb_subnet_1_id    = "ocid1.subnet.xxxxxxxxxxxxxxx"
lb_min_bandwidth  = 10
lb_max_bandwidth  = 100
```

## IDCS

In order to use IDCS for user authentication in your WebLogic applications, you can set the variables described in the [idcs_variables.tf](./terraform/idcs_variables.tf) file.

This is an example:
```terraform
is_idcs_selected      = true
idcs_host             = "identity.oraclecloud.com"
idcs_tenant           = "idcs-xxxxxxxxxxxxxxx"
idcs_client_id        = "<idcs_client_id>"
idcs_client_secret_id = "ocid1.vaultsecret.xxxxxxxxxxxxxxx"
```
There are some prerequisites for using IDCS. See the `Create a Confidential Application`section in the
[documentation](https://docs.oracle.com/en/cloud/paas/weblogic-cloud/user/you-begin-oracle-weblogic-cloud.html).

## File system

To create a file system and mount to the WebLogic VMs of your stack, refer to the [fss_variables.tf](./terraform/fss_variables.tf)
file for the variables to use.

This is an example of how to create new file system and mount target:
```terraform
add_fss                  = true
fss_availability_domain  = "<availability domain name>"
```

## Observability

You can configure OCI logging to send WebLogic logs to an OCI log. You can also enable APM support to push WebLogic server
metrics to an APM domain.

This is an example of how to configure both OCI logging and APM support:
```terraform
use_oci_logging = true
use_apm_service = true
apm_domain_id   = "ocid1.apmdomain.oc1.phx.xxxxxxxxxxxxxxx"
```
Review the [observability_variables.tf](./terraform/observability_variables.tf) file for more details.

## Autoscaling
To configure the stack to automatically add or remove servers based on performance metrics, refer to the
[autoscaling_variables.tf](./terraform/autoscaling_variables.tf) file for the variables to use.

This is an example of how to configure autoscaling:
```terraform
use_autoscaling       = true
wls_metric            = "CPU Load"
min_threshold_percent = 10
max_threshold_percent = 20
ocir_user             = "<ocir_user>"
ocir_auth_token_id    = "ocid1.vaultsecret.oc1.phx.xxxxxxxxxxxxxxx"
```
There are some prerequisites for using autoscaling. See the `Autoscaling`section in the
[documentation](https://docs.oracle.com/en/cloud/paas/weblogic-cloud/user/you-begin-oracle-weblogic-cloud.html).                                 
Note that autoscaling is not supported when creating a stack using Terraform CLI. You need to create a [Resource Manager][orm]
stack, or use the [Marketplace][marketplace].

[marketplace]: https://docs.oracle.com/iaas/Content/Marketplace/Concepts/marketoverview.htm
[orm]: https://docs.cloud.oracle.com/iaas/Content/ResourceManager/Concepts/resourcemanager.htm