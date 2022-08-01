
variable "tenancy_id" {
  type        = string
  description = "The OCID of the tenancy where the bastion instance will be created"
  validation {
    condition     = length(regexall("^ocid1.tenancy.*$", var.tenancy_id)) > 0
    error_message = "The value for tenancy_id should start with \"ocid1.tenancy.\"."
  }
}
variable "availability_domain" {
  type        = string
  description = "The availability domain where the bastion instance will be created"
}

variable "compartment_id" {
  type        = string
  description = "The OCID of the compartment where the bastion instance will be created"
  validation {
    condition     = length(regexall("^ocid1.compartment.*$", var.compartment_id)) > 0
    error_message = "The value for compartment_id should start with \"ocid1.compartment.\"."
  }
}

variable "region" {
  type        = string
  description = "The region where the bastion instance will be created. Example: us-phoenix-1"
}

variable "instance_shape" {
  type        = string
  description = "The shape of the bastion instance. For example: VM.Standard2.2"
  validation {
    condition     = var.instance_shape != ""
    error_message = "The value for instance_shape cannot be empty."
  }
}

variable "ocpu_count" {
  type        = number
  description = "The number of ocpus for the compute instance. This variable is not used if the instance shape is not a Flex shape"
  default     = 1
  validation {
    condition     = var.ocpu_count > 0
    error_message = "The value for ocpu_count must be greater than 0."
  }
}

variable "instance_name" {
  type        = string
  description = "The name to be used as display_name for the bastion compute and its associated reserved public ip, if specified"
  default     = "bastion-instance"
}

variable "instance_count" {
  type        = number
  description = "Set to 0 if a bastion instance should not be created. Set to 1 if a bastion instance should be created"
  validation {
    condition     = var.instance_count == 0 || var.instance_count == 1
    error_message = "The allowed values for instance_count are 0 or 1."
  }
}

variable "vm_count" {
  type        = number
  description = "Number of WebLogic VM nodes the WebLogic for OCI instance associated to this bastion instance has"
  validation {
    condition     = var.vm_count > 0
    error_message = "The value for vm_count must be greater than 0."
  }
}

variable "is_bastion_instance_required" {
  type        = bool
  description = "Set to true if a bastion instance should be created"
  default     = true
}

variable "is_bastion_with_reserved_public_ip" {
  type        = bool
  description = "Set to true if the bastion instance should be created with a new reserved public IP"
  default     = false
}

variable "existing_bastion_instance_id" {
  type        = string
  description = "Specify the OCID of a compute instance that will be used as bastion, instead of creating a new bastion compute"
  validation {
    condition     = var.existing_bastion_instance_id == "" || length(regexall("^ocid1.instance.*$", var.existing_bastion_instance_id)) > 0
    error_message = "The value for existing_bastion_instance_id should be blank or start with \"ocid1.instance.\"."
  }
}

variable "bastion_subnet_id" {
  type        = string
  description = "The OCID of the subnet where the bastion compute will be created"
  validation {
    condition     = length(regexall("^ocid1.subnet.*$", var.bastion_subnet_id)) > 0
    error_message = "The value for bastion_subnet_id should start with \"ocid1.subnet.\"."
  }
}

variable "ssh_public_key" {
  type        = string
  description = "This public key is put in the list of allowed keys in the bastion compute for opc user. The opc user can ssh to the compute with the corresponding private key"
}

variable "bastion_bootstrap_file" {
  type        = string
  description = "The path of the script that will be run after the bastion instance is created. Relative to the module"
  default     = "userdata/bastion-bootstrap"
}

variable "instance_image_id" {
  type        = string
  description = "The OCID of the compute image used to create the bastion instance"
  validation {
    condition     = length(regexall("^ocid1.image.*$", var.instance_image_id)) > 0
    error_message = "The value for instance_image_id should start with \"ocid1.image.\"."
  }
}

variable "use_existing_subnet" {
  type        = bool
  description = "Set to true if the bastion instance is created in a existing subnet (a subnet that was not created as part of the WebLogic for OCI stack to which this bastion belongs)"
}

variable "disable_legacy_metadata_endpoint" {
  type        = bool
  description = "Set to true to disable IMDSv1 endpoints in the bastion compute and use IMDSv2 endpoints instead"
  default     = true
}

variable "defined_tags" {
  type        = map
  description = "A map with keys that will be added as defined tags to the bastion compute instance"
  default     = {}
}

variable "freeform_tags" {
  type        = map
  description = "A map with keys that will be added as freeform tags to the bastion compute instance"
  default     = {}
}