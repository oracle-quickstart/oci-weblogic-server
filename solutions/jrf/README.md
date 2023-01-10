## WebLogic JRF domain with OCI DB

This solution creates single/multi node Weblogic cluster with OCI Database and Oracle Identity Cloud Service fronted by a load balancer. The solution will create only one stack at time and further modifications that are done will be done on the same stack.

This topology uses existing infrastructure.
- Existing VCN and existing subnets with private WebLogic subnet.
- OCI DB in a different VCN
- Existing Public load balancer

Oracle Identity Cloud Service (IDCS) is used to authenticate user.

[Full Topology Diagram](../solutions/jrf/Topology.png)

The above diagram shows a topology that includes most of the components supported by the Terraform scripts. 
In this scenario, the WebLogic servers are in a private subnet. To access the applications running on WebLogic, an existing OCI load balancer in public regional subnet is used. A bastion instance with a public IP address is provisioned to allow access to the VMs in the private subnet. The Oracle WebLogic Server domain is configured to use Oracle Identity Cloud Service for authentication.

The diagram shows the stack using a database located in a VCN different from the one used by the WebLogic for OCI stack, with VCN peering. Peering is necessary because DB VCN is different from Weblogic VCN. Since existing VCNs are used here, VCNs for WebLogic Server compute instances and the Oracle Cloud Infrastructure Application Database are peered manually before creating the stack for the Oracle WebLogic Server for OCI domain. To peer the VCNs manually, see [Manual VCN Peering](https://docs.oracle.com/en/cloud/paas/weblogic-cloud/user/configure-database-parameters.html#GUID-6A39A2A7-EF6C-408E-B5C7-C44089A9B134__MANUAL_VCN_PEERING).

## Before You Begin with Oracle WebLogic Server for OCI
Refer to the [documentation](https://docs.oracle.com/en/cloud/paas/weblogic-cloud/user/you-begin-oracle-weblogic-cloud.html) for the pre-requisite steps to using Oracle WebLogic Server for OCI.

## Workspace Checkout
- Install latest version of git from http://git-scm.com/downloads
- For Linux and Mac: Add the git to the PATH
- git clone https://github.com/oracle-quickstart/weblogic-server-for-oci.git

## Organization
The directory weblogic-server-for-oci/solutions/jrf consists of the following terraform files: 

- jrf_instance.tfvars - Weblogic instance, Bastion instance and Network configuration
- existing_lb.tfvars - Load Balancer configuration
- oci_db.tfvars  - OCI Database configuration
- idcs.tfvars - IDCS configuration

The directory weblogic-server-for-oci/solutions/common consists of the following:
- tenancy.tfvars - tenancy configuration

## Using the terraform command line tool
cd weblogic-server-for-oci/terraform

Initialize the terraform provider plugin
$ terraform init

Update the variable values in tfvars files under directories terraform/solutions/common and terraform/solutions/jrf according to the user specific values
Invoke apply passing all *.tfvars files as input
$ terraform apply -var-file=../solutions/common/tenancy.tfvars -var-file=inputs/mp_image_ee_byol.tfvars -var-file=../solutions/jrf/jrf_instance.tfvars -var-file=../solutions/jrf/existing_lb.tfvars -var-file=../solutions/jrf/idcs.tfvars var-file=../solutions/jrf/oci_db.tfvars

To destroy the infrastructure
$ terraform destroy var-file=../solutions/common/tenancy.tfvars -var-file=inputs/mp_image_ee_byol.tfvars -var-file=../solutions/jrf/jrf_instance.tfvars -var-file=../solutions/jrf/existing_lb.tfvars -var-file=../solutions/jrf/idcs.tfvars var-file=../solutions/jrf/oci_db.tfvars