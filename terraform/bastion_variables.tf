# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "is_bastion_instance_required" {
  type        = bool
  description = "Set to true to use a bastion, either new or existing. If existing_bastion_instance_id is blank, a new bastion will be created"
  default     = false
}

variable "existing_bastion_instance_id" {
  type        = string
  description = "The OCID of a compute instance that will work as bastion"
  default     = ""
}

# TODO: remove this when UI uses control with flex shape
variable "bastion_instance_shape" {
  type        = string
  description = "Shape of bastion VM instances"
  default     = "VM.Standard.E4.Flex"
}

# TODO: uncomment this when UI uses control with flex shape
#variable "bastion_instance_shape" {
#  type = map(string)
#  description = "Shape of bastion VM instances"
#  default = {
#    "instanceShape" = "VM.Standard.E4.Flex",
#    "ocpus"         = "1",
#    "memory"        = "16"
#  }
#}

variable "bastion_ssh_private_key" {
  type        = string
  description = "The path to the file that contains the private ssh key for an existing bastion instance"
  default     = ""
}

variable "is_bastion_with_reserved_public_ip" {
  type        = bool
  description = "Creates reserved public ip for bastion instance. Applicable only for new bastion, not for existing"
  default     = false
}

variable "existing_bastion_nsg_id" {
  type        = string
  description = "The OCID of the pre-created NSG that should be attached to the bastion instance"
  default     = ""
}
