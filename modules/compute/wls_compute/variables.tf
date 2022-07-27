
variable "tenancy_ocid" {
  type = string
  description = "The OCID of the tenancy where the compute will be created"
}

variable "region" {
  type = string
  description = "The OCI region where the compute will be created"
}

variable "compartment_ocid" {
  type = string
  description = "The OCID of the compartment where the compute will be created"
}

variable "availability_domain" {
  type = string
  description = "The label of the availability domain where the compute will be created"
}

variable "instance_image_ocid" {
  type = string
  description = "The OCID of the image used to create the compute instance"
}

#TODO (robesanc): Rename to use convention and change type to number
variable "numVMInstances" {
  type    = string
  description = "The number of compute instances that will be created"
  default = "2"
}

variable "ssh_public_key" {
  type = string
  description = "The ssh public key that will be added to the compute to allow the opc user to ssh to it using its corresponding private key"
}

variable "compute_name_prefix" {
  type = string
  description = "The prefix for the name of the compute. If not specified, a default value will be used"
  default = "wls-instance"
}

variable "vnic_prefix" {
  type = string
  description = "The prefix for the name of the compute. If not specified, a default value will be used"
  default = "wls"
}

variable "assign_public_ip" {
  type = bool
  description = "Set to true if you want the compute instance to have a public IP in addition to the private ip. Use with caution. "
}

variable "disable_legacy_metadata_endpoint" {
  type = bool
  description = "Set to true to disable the legacy metadata endopoint (recommended)"
  default = true
}


#TODO (robesanc): Is this really required? do we care if the VCN is existing or new?
//WLS existing VCN Id
variable "wls_existing_vcn_id" {
  type = string
  description = "The OCID of the existing VCN where the subnet the compute instance will be created is located. Specify only if the VCN was not created as part of the WebLogic for OCI stack"
  default = ""
}

variable "wls_vcn_cidr" {
  type = string
  description = "The CIDR of the VCN where the subnet the compute instance will be created is located"
}

variable "wls_subnet_id" {
  type = string
  description = "The OCID of the existing subnet where the compute instance will be created. Provide a blank value if a new subnet was created as part of the WebLogic for OCI stack"
}

variable "use_regional_subnet" {
  type = bool
  description = "Set to true if the subnet where the compute instance will be located is a regional subnet"
}

#TODO (robesanc): subnet_ocid and wls_subnet_id seems to be the same. Can we remove one?
variable "subnet_ocid" {
  type = string
  description = "The OCID of the subnet where the compute instance will be created"
}

variable "network_compartment_id" {
  type = string
  description = "The OCID of the compartment where the network resources associated to this compute instance (e.g. VCN, subnet) are located"
}

variable "add_loadbalancer" {
  type = bool
  description = "Set to true of a load balancer was created as part of the WebLogic for OCI stack"
}

variable "is_lb_private" {
  type = bool
  description = "Set to true if a load balancer was created as part of the WebLogic for OCI stack and is private. Set to false if a load balancer was created as part of the WebLogic for OCI stack and is public"
}
variable "load_balancer_id" {
  type = string
  description = "The OCID of the load balancer that was created as part of the WebLogic for OCI stack"
}

variable "bootStrapFile" {
  type    = string
  description = "The path of the script that will be run after the compute instance is created, to setup the WebLogic domain. Relative to module"
  default = "userdata/bootstrap"
}

#TODO (robesanc): Looks like this variable is no longer used
variable "rebootFile" {
  type    = string
  default = "./modules/compute/instance/userdata/reboot"
}

variable "instance_shape" {
  type = string
  description = "The OCI VM shape used to create the compute instance"
}

variable "wls_ocpu_count" {
  type = number
  description = "OCPU count for compute instance"
  default = 1
}

#TODO (robesanc): This variable is used but I do not understand its purpose
variable "num_volumes" {
  type    = string
  description = ""
  default = "1"
}

#TODO (robesanc) : I think this is no longer used.
variable "volume_name" {
  type = string
  description = "The name of the volume attached to the compute"
}

#TODO (robesanc) : I think this is no longer used.
variable "volume_size" {
  type = string
  description = "The size of the volumes"
  default = "50"
}

variable "volume_map" {
  type = list
  description = "List of volumes to be mounted in the compute instance. Each element must be an object with the following attributes: volume_mount_point, display_name, device"
  default = [
    {
      volume_mount_point = "/u01/app"
      display_name       = "middleware"
      device             = "/dev/sdb"
    },
    {
      volume_mount_point = "/u01/data"
      display_name       = "data"
      device             = "/dev/sdc"
    }
  ]
}

variable "volume_info_file" {
  type = string
  description = "Path of the files where the information of the block volumes to be mounted on the VM is stored"
  default = "/tmp/volumeInfo.json"
}

variable "is_bastion_instance_required" {
  type = bool
  description = "Set to true if a bastion instance was created as part of the WebLogic for OCI stack"
  default = false
}

variable "is_bastion_with_reserved_public_ip" {
  type = bool
  description = "Set to true if a bastion instance with reserved public IP was created as part of the WebLogic for OCI stack"
  default = false
}

variable "domain_dir" {
  type = string
  description = "The directory where the WebLogic domain will be created in the compute instance"
  default = "/u01/data/domains"
}

variable "logs_dir" {
  type = string
  description = "The path where the provisioning logs and other logs will be stored in the compute instance"
  default = "/u01/logs"
}

variable "log_level" {
  type = string
  description = "The level of messages to be written to the provisioning logs. Allowed values: INFO, DEBUG"
  default = "INFO"
}

variable "deploy_sample_app" {
  type    = bool
  description = "Set to true of you want to have a sample application deployed to the WebLogic domain after creating it, to validate the domain was started successfully. This option is ignored for Standard Edition"
  default = true
}

variable "opc_key" {
  type = map
  description = "A map with the keys public_key_openssh and private_key_pem. This key allows opc user ssh to the compute instance during provisioning"
}
variable "oracle_key" {
  type = map
  description = "A map with the keys public_key_openssh and private_key_pem. This key allows oracle user ssh to the compute instance during provisioning"
}

variable "status_check_timeout_duration_secs" {
  type = string
  description = "The timeout (in seconds) for calls to provisioning status checks"
  default = "1800"
}

# TODO: (robesanc) How are we going to publish these versions to users? Maybe this is not needed in github
variable "tf_script_version" {
  type = string
  description = "The version of the provisioning scripts in the VM used to create this compute instance"
}

variable "vmscripts_path" {
  type = string
  description = "The location of the provisioning scripts in the VM used to create this compute instance"
  default = "/u01/zips/TF/wlsoci-vmscripts.zip"
}

variable "allow_manual_domain_extension" {
  type        = bool
  description = "Set to true to indicate that the domain will not be automatically extended for managed servers, meaning that users have to manually extend the domain in the compute instance"
  default     = false
}


#TODO (robesanc): Ask Abhi what is this for
variable "patching_tool_key" {
  type = string
  default = "wiPECMve6esBkBF0g6c5mQ=="
}

# TODO (robesanc): do we need to expose this? Also, evaluate to change to list instead of string
variable "supported_patching_actions" {
  type = string
  description = "Comma-separated list of patching tool actions supported by this compute instance"
  default = "setup,list,info,download,apply,upgrade"
}

variable "dg_defined_tags" {
  type    = map
  description = "Dynamic-group tags. Tags that are used to indicate to which dynamic group the compute instance belongs. These are added to the compute as definied tags"
  default = {}
}

variable "defined_tags" {
  type    = map
  description = "Defined tags to be added to the compute instance"
  default = {}
}

variable "freeform_tags" {
  type    = map
  description = "Free-form tags to be added to the compute instance"
  default = {}
}

# TODO (robesanc): Evaluate to remove dev mode.
variable "mode" {
  type = string
  description = "Mode if provisioning. Accepted values: PROD, DEV"
}
