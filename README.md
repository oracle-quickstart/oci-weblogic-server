# OCI Terraform stack for WebLogic Server

The OCI Terraform stack for WebLogic Server allows you to create and configure a WebLogic domain in
[Oracle Cloud Infrastructure (OCI)][oci], in minutes. It will create and/or configure multiple OCI services such as
Compute, Network, OCI Database, Autonomous Database, Identity Cloud Service, Logging, File System, Application
Performance Monitoring and Autoscaling. The WebLogic domain created can be scaled by updating a terraform variable to indicate
the desired number of nodes and re apply the stack or auto-scaling can be configured to automatically adapt to different
workloads in real time.

The OCI Terraform stack for WebLogic Server is available through the Oracle Quick Start or through the
[Oracle Cloud Infrastructure Marketplace][marketplace] as one of the multiple Oracle WebLogic Server for OCI applications.
After launching one of these applications, you use a simple wizard interface to configure and provision your domains along
with any supporting cloud resources like compute instances, networks and load balancers.

For more details about deploying the OCI Terraform stack for WebLogic Server through the OCI Marketplace, visit the
["Using Oracle WebLogic Server for OCI"](https://docs.oracle.com/en/cloud/paas/weblogic-cloud/user/index.html) guide.

## Common Topologies

The OCI Terraform stack for WebLogic Server offers many options to customize your environment, to create new resources or configure
existing resources or services such as Network, Oracle Database, Oracle Identity Cloud Service, Logging, File System, etc.

The [solutions](./solutions) directory contains examples of different topologies that can be created with this Terraform
template, with sample tfvars files, and instructions to create the stack.

The following topologies are included:

| Solution                     | Features                                                                                                                              |
|------------------------------|---------------------------------------------------------------------------------------------------------------------------------------|
|[non_jrf](./solutions/non_jrf)|<ul><li>New VCN</li><li>New public load balancer</li><li>New bastion</li><li>New file system and mount target</li><li>OCI Logging</li> |
|[jrf](./solutions/jrf)|<ul><li>Existing subnets</li><li>Existing load balancer</li><li>New bastion</li><li>JRF with OCI DB</li><li>IDCS</li>                          |

Review each solution for more details.

## Before You Begin with OCI Terraform stack for WebLogic Server

Whether you use Terraform CLI, ORM or the Marketplace to create a stack, you need to perform some pre-requisites. Refer
to the [documentation](https://docs.oracle.com/en/cloud/paas/weblogic-cloud/user/you-begin-oracle-weblogic-cloud.html) for
the pre-requisite steps to use the OCI Terraform stack for WebLogic Server.

For pre-requisites specific to Terraform CLI and ORM, see their corresponding section.

## Create the Stack Using the OCI Marketplace

The WebLogic Server for OCI applications available in the Marketplace are:
- [Oracle WebLogic Server Enterprise Edition (UCM)](https://cloudmarketplace.oracle.com/marketplace/en_US/listing/72493372)
- [Oracle WebLogic Suite (UCM)](https://cloudmarketplace.oracle.com/marketplace/en_US/listing/72492657)
- [Oracle WebLogic Server Standard Edition (BYOL)](https://cloudmarketplace.oracle.com/marketplace/en_US/listing/65022652)
- [Oracle WebLogic Server Enterprise Edition (BYOL)](https://cloudmarketplace.oracle.com/marketplace/en_US/listing/63497374)
- [Oracle WebLogic Suite (BYOL)](https://cloudmarketplace.oracle.com/marketplace/en_US/listing/63498586)

To create, manage and destroy the OCI Terraform stack for WebLogic Server as WebLogic Server for OCI using the Marketplace,
follow the instructions in the [documentation](https://docs.oracle.com/en/cloud/paas/weblogic-cloud/user/create-stack1.html).

## Create Stack Using the Terraform CLI

You need to install the following software in your computer to create a stack using Terraform CLI:
- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git). Install the latest version
- [Terraform](https://www.terraform.io/). The scripts in this Quick Start requires Terraform version >= 1.1.2, < 1.2.0

First, get a local copy of this repo. You can make that with the commands:

```bash
git clone https://github.com/oracle-quickstart/oci-weblogic-server.git
cd oci-weblogic-server/terraform
ls
```
Example output:

```bash
$ git clone https://github.com/oracle-quickstart/oci-weblogic-server.git
Cloning into 'oci-weblogic-server'...
remote: Enumerating objects: 2522, done.
remote: Counting objects: 100% (646/646), done.
remote: Compressing objects: 100% (324/324), done.
remote: Total 2522 (delta 449), reused 440 (delta 318), pack-reused 1876
Receiving objects: 100% (2522/2522), 972.92 KiB | 1.54 MiB/s, done.
Resolving deltas: 100% (1735/1735), done.
$ cd oci-weblogic-server/terraform
$ ls
autoscaling_variables.tf  data_sources.tf  edition.tf        idcs_variables.tf  locals.tf  modules/         network_variables.tf        oci_images.tf  outputs.tf   schema.yaml        variables.tf  weblogic_variables.tf
bastion_variables.tf      db_variables.tf  fss_variables.tf  images/            main.tf    mp_variables.tf  observability_variables.tf  orm/           provider.tf  schema_14110.yaml  versions.tf
$
```

*NOTE*: All the `terraform` commands must be run from the `terraform` directory.

Next, initialize the directory with the module in it. This makes the module aware of the OCI provider. You can do this by
running:

```bash
terraform init
```

Example output:

```bash
$ terraform init
Initializing modules...
- bastion in modules\compute\bastion
- compute in modules\compute\wls_compute
- compute.compute-keygen in modules\compute\keygen
- compute.data-volume in modules\compute\volume
- compute.data_volume_attach in modules\compute\volume
- compute.middleware-volume in modules\compute\volume
- compute.middleware_volume_attach in modules\compute\volume
- compute.wls-instances in modules\compute\instance
- fss in modules\fss
- load-balancer in modules\lb\loadbalancer
- load-balancer-backends in modules\lb\backends
- network-bastion-nsg in modules\network\nsg
- network-bastion-subnet in modules\network\subnet
- network-compute-admin-nsg in modules\network\nsg
- network-compute-managed-nsg in modules\network\nsg
- network-lb-nsg in modules\network\nsg
- network-lb-subnet-1 in modules\network\subnet
- network-mount-target-nsg in modules\network\nsg
- network-mount-target-private-subnet in modules\network\subnet
- network-vcn in modules\network\vcn
- network-vcn-config in modules\network\vcn-config
- network-wls-private-subnet in modules\network\subnet
- network-wls-public-subnet in modules\network\subnet
- observability-autoscaling in modules\observability\autoscaling
- observability-common in modules\observability\common
- observability-logging in modules\observability\logging
- policies in modules\policies
- provisioners in modules\provisioners
- system-tags in modules\resource-tags
- validators in modules\validators
- vcn-peering in modules\network\vcn-peering

Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/null versions matching "~> 3.1.1"...
- Finding oracle/oci versions matching "4.96.0"...
- Finding hashicorp/random versions matching "~> 3.4.3"...
- Finding hashicorp/template versions matching "~> 2.2.0"...
- Finding hashicorp/tls versions matching "~> 4.0.3"...
- Finding hashicorp/time versions matching "~> 0.9.0"...
- Installing hashicorp/template v2.2.0...
- Installed hashicorp/template v2.2.0 (signed by HashiCorp)
- Installing hashicorp/tls v4.0.4...
- Installed hashicorp/tls v4.0.4 (signed by HashiCorp)
- Installing hashicorp/time v0.9.1...
- Installed hashicorp/time v0.9.1 (signed by HashiCorp)
- Installing hashicorp/null v3.1.1...
- Installed hashicorp/null v3.1.1 (signed by HashiCorp)
- Installing oracle/oci v4.96.0...
- Installed oracle/oci v4.96.0 (signed by a HashiCorp partner, key ID 1533A49284137CEB)
- Installing hashicorp/random v3.4.3...
- Installed hashicorp/random v3.4.3 (signed by HashiCorp)

Partner and community providers are signed by their developers.
If you'd like to know more about provider signing, you can read about it here:
https://www.terraform.io/docs/cli/plugins/signing.html

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

```

### Configure variables for the stack

First, you need to set the image variables, depending on which WebLogic edition and type of license you want to use,
BYOL license or UCM license, when creating the stack.

The following files contain the values for those variables:
- [mp_image_se_byol.tfvars](./terraform/images/mp_image_se_byol.tfvars): WebLogic Standard Edition - BYOL
- [mp_image_ee_byol.tfvars](./terraform/images/mp_image_ee_byol.tfvars): WebLogic Enterprise Edition - BYOL
- [mp_image_ee_ucm.tfvars](./terraform/images/mp_image_ee_ucm.tfvars): WebLogic Enterprise Edition - UCM
- [mp_image_suite_byol.tfvars](./terraform/images/mp_image_suite_byol.tfvars): WebLogic Suite - BYOL
- [mp_image_suite_ucm.tfvars](./terraform/images/mp_image_suite_ucm.tfvars): WebLogic Suite - UCM

To use one of the files above:
- Copy the file from the `terraform/images` directory, to the `terraform` directory
- Rename the file from `terraform/mp_image_<edition>_<license>.tfvars` to `terraform/mp_image_<edition>_<license>.auto.tfvars`

For example, if you want to create a WebLogic Enterprise Edition UCM stack, copy the file `terraform/images/mp_image_ee_ucm.tfvars`
to `terraform/mp_image_ee_ucm.auto.tfvars`

Next, you need to configure [variables](./VARIABLES.md) to drive the stack creation. This can be done by creating a
`terraform.tfvars` file in the `terraform` directory, using variables copied from the tfvars files from one of the [solutions](./solutions)
into the `terraform.tfvars` file.

Make sure the plan looks good. Once you created `terraform.tfvars` in the `terraform` directory, just run:

```bash
terraform plan
```

### Deploy

If terraform plan is successful, you can run terraform apply to deploy the stack:

```bash
terraform apply
```

You'll need to enter yes when prompted.

After the stack creation is complete, if you need to make changes to your stack (adding a new VM for example), you can edit
the variables in your `terraform.tfvars` file, and run the following commands:

```bash
terraform plan
# If the plan looks OK, run apply.
terraform apply
```
*NOTE*: Not all variables can be changed after a stack is deployed.

### Destroy the Deployment

**Important:** Refer to [documentation](https://docs.oracle.com/en/cloud/paas/weblogic-cloud/user/delete-domain.html)
for steps to perform before running *terraform destroy*.

When you no longer need the deployment, you can run this command to destroy it:

```bash
terraform destroy
```

You'll need to enter yes when prompted.

## Create Stack Using OCI Resource Manager

Oracle Cloud Infrastructure [Resource Manager (ORM)][orm] allows you to manage your Terraform configurations and state.
To simplify getting started, the Terraform zip files for use with ORM are created as part of each [release](https://github.com/oracle-quickstart/oci-weblogic-server/releases).

If you want to build the zip file to create an ORM stack, you need the following software:

*Linux*

- No additional software is required

*Mac OS*

- GNU sed

*Windows*

- Git bash (included in [Git for Windows](https://gitforwindows.org/)) or any other software that allows you to run bash
  scripts in Windows
- The build scripts use the `zip` command. This is an example of how you can use a program like [7-zip](https://www.7-zip.org/)
  with the build scripts
1. Install 7-zip
2. Locate the file 7z.exe. Copy it to a directory that can be added to your path (e.g. ~/bin)
3. Create a script called `zip` in the same directory (e.g. ~/bin) with the following content:
```bash
#!/bin/bash
7z.exe a $@
```
4. Add the directory where you put the files (e.g. ~/bin) in your PATH
5. Verify zip command is recognized:
```bash
$ zip
 
7-Zip 22.01 (x64) : Copyright (c) 1999-2022 Igor Pavlov : 2022-07-15
 
 
 
Command Line Error:
Cannot find archive name
```

### Create the stack

To build the zip file to create an ORM stack, run the `builds/build_mp_bundles.sh` script.
```bash
$ cd builds/
$ ./build_mp_bundles.sh
Build the Oracle Resource Manager (ORM) bundles to deploy in Marketplace

Arguments: build_mp_bundles.sh -e|--edition <EE|SUITE|SE> -v|--version <12.2.1.4|14.1.1.0> -t|--type <UCM|BYOL> --all
options:
-e, --edition     WebLogic edition. Supported values are EE, SUITE, or SE. Optional when --all option is provided
-v, --version     WebLogic version. Supported values are 12.2.1.4 or 14.1.1.0. Optional when --all option is provided
-t, --type        Type of bundle. Supported values are UCM or BYOL. Optional when --all option is provided
--all             All bundles
```

For example, to create the zip file for a WebLogic 12.2.1.4 Enterprise Edition stack with BYOL license, run the following
command:

```bash
cd builds
./build_mp_bundles.sh --edition EE --version 12.2.1.4 --type BYOL
```

The zip files are generated in the `builds/binaries` directory.

Follow [these steps](https://docs.oracle.com/en-us/iaas/Content/ResourceManager/Tasks/create-stack-local.htm) to create
a ORM stack, using either a zip file from one of the [releases](https://github.com/oracle-quickstart/oci-weblogic-server/releases),
or a zip file generated manually with the `build_mp_bundles.sh` script.

### Deploy the stack

After you create the stack, you can run a `plan` [job](https://docs.oracle.com/en-us/iaas/Content/ResourceManager/Tasks/create-job-plan.htm)
to validate the resources that will be created.

If the plan looks good, you can run an `apply` [job](https://docs.oracle.com/en-us/iaas/Content/ResourceManager/Tasks/create-job-apply.htm)
to deploy the stack.

After the stack creation is complete, you can
[manage the domain](https://docs.oracle.com/en/cloud/paas/weblogic-cloud/user/manage-domain-oracle-weblogic-cloud.html).

### Destroy the stack

**Important:** Refer to [documentation](https://docs.oracle.com/en/cloud/paas/weblogic-cloud/user/delete-domain.html) for
steps to perform before running a `destroy` job.

When you no longer need the deployment, you can run a
`destroy` [job](https://docs.oracle.com/en-us/iaas/Content/ResourceManager/Tasks/create-job-destroy.htm) to destroy the stack.

## Troubleshoot

Refer to [documentation](https://docs.oracle.com/en/cloud/paas/weblogic-cloud/user/troubleshoot-oracle-weblogic-cloud.html)
to identify common problems and learn how to diagnose and solve them.

## License

The OCI Terraform stack for WebLogic Server is licensed under the Universal Permissive License 1.0.
See [LICENSE](./LICENSE) for more details.

The OCI Terraform stack for WebLogic Server does not include entitlement to Oracle WebLogic Server. The entitlement of
Oracle WebLogic Server within the OCI Terraform stack for WebLogic Server can be obtained by using the Oracle WebLogic
Server for OCI images or by using a valid WebLogic Server license with the stack.

### Universal Credits Model (UCM)
The Oracle WebLogic Server for OCI images that include entitlement of Oracle WebLogic Server can be found here:
- Oracle WebLogic Server Enterprise Edition UCM image: https://cloudmarketplace.oracle.com/marketplace/en_US/listing/70276523
- Oracle WebLogic Suite UCM image: https://cloudmarketplace.oracle.com/marketplace/en_US/listing/70277452

When using the Oracle WebLogic Server Enterprise Edition UCM image, the WebLogic for OCI license in governed by the
following terms: https://cloudmarketplace.oracle.com/marketplace/content?contentId=70262301&render=inline

When using the Oracle WebLogic Suite UCM image, the WebLogic for OCI license in governed by the following terms:
https://cloudmarketplace.oracle.com/marketplace/content?contentId=70262277&render=inline

### Bring Your Own License (BYOL)

When deploying using BYOL, the WebLogic for OCI license is governed by the following Licensing terms:
https://cloudmarketplace.oracle.com/marketplace/content?contentId=18088784&render=inline

[wlsoci]: https://docs.oracle.com/en/cloud/paas/weblogic-cloud/index.html
[oci]: https://cloud.oracle.com/cloud-infrastructure
[marketplace]: https://docs.oracle.com/iaas/Content/Marketplace/Concepts/marketoverview.htm
[orm]: https://docs.cloud.oracle.com/iaas/Content/ResourceManager/Concepts/resourcemanager.htm
[vault]: https://docs.cloud.oracle.com/iaas/Content/KeyManagement/Concepts/keyoverview.htm
[tf]: https://www.terraform.io