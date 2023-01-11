## WebLogic non JRF domain

This solution creates single/multi node WLS cluster with Oracle Cloud Infrastructure File Storage service(FSS) fronted
by a load balancer. The solution will create only one stack at time and further modifications that are done will be
done on the same stack.

This topology creates WLS in private subnet. Following regional subnets are created under new VCN.
- WLS Regional Private Subnet
- Bastion Regional Public Subnet
- Loadbalancer Frontend Public Subnet
- Mount Target Regional Private Subnet

![Full Topology Diagram](Topology.png)

The above diagram shows a topology that includes most of the components supported by the Terraform scripts
In this scenario, the WebLogic servers are created in a private subnet. To access the applications running on WebLogic, a new OCI load balancer in public regional subnet will be created. A bastion instance with a public ip address is provisioned to allow access to the WebLogic VMs in the private subnet. New file system(FSS) and mount target will be created in a private subnet to support mounting shared storage for WLS instance data and middleware. The file system(FSS) will be mounted on each WLS instance at /u01/shared.

## Before You Begin with Oracle WebLogic Server for OCI
Refer to the [documentation](https://docs.oracle.com/en/cloud/paas/weblogic-cloud/user/you-begin-oracle-weblogic-cloud.html) for the pre-requisite steps to using Oracle WebLogic Server for OCI.

## Workspace Checkout
- Install latest version of git from http://git-scm.com/downloads
- For Linux and Mac: Add the git to the PATH
- Clone the code using the command:

```bash
git clone https://github.com/oracle-quickstart/weblogic-server-for-oci.git
```

## Organization
The directory weblogic-server-for-oci/solutions/non_jrf  consists of the following terraform files:

- nonjrf_instance.tfvars - wls instance, bastion instance , and network configuration
- lb.tfvars - load balancer configuration
- fss.tfvars  - file system configuration

The directory weblogic-server-for-oci/solutions/common  consists of the following:
- tenancy.tfvars - tenancy configuration

## Using the terraform command line tool
```bash
cd weblogic-server-for-oci/terraform
```

Initialize the terraform provider plugin
```bash
terraform init
```

Update the variable values in tfvars files under directories terraform/solutions/common and terraform/solutions/non_jrf according to the user specific values
Invoke apply passing all *.tfvars files as input
```bash
terraform apply -var-file=../solutions/common/tenancy.tfvars -var-file=inputs/mp_image_ee_byol.tfvars -var-file=../solutions/non_jrf/nonjrf_instance.tfvars -var-file=../solutions/non_jrf /lb.tfvars -var-file=../solutions/non_jrf/fss.tfvars
```

To destroy the infrastructure
```bash
terraform destroy -var-file=../solutions/common/tenancy.tfvars -var-file=../solutions/common/mp_byol.tfvars -var-file=../solutions/non_jrf/nonjrf_instance.tfvars -var-file=../solutions/non_jrf/lb.tfvars -var-file=../solutions/non_jrf/fss.tfvars
```
