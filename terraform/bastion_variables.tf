# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "is_bastion_instance_required" {
  type        = bool
  description = "Set to true to use a bastion, either new or existing. If existing_bastion_instance_id is blank, a new bastion will be created"
  default     = true
}

variable "existing_bastion_instance_id" {
  type        = string
  description = "The OCID of a compute instance that will work as bastion"
  default     = ""
}

variable "bastion_instance_shape" {
  type = map(string)
  default = {
    "instanceShape" = "VM.Standard.E4.Flex",
    "ocpus"         = "1",
    "memory"        = "16"
  }
  description = "default shape of bastion VM instances"
}

variable "bastion_ssh_private_key" {
  type        = string
  description = "Private ssh key for existing bastion instance"
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
