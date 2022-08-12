variable "is_bastion_instance_required" {
  type = bool
  description = "Set to true to use a bastion, either new or existing. If existing_bastion_instance_id is blank, a new bastion will be created"
}

variable "existing_bastion_instance_id" {
  type = string
  description = "The OCID of a compute instance that will work as bastion"
  default = ""
}

variable "bastion_instance_shape" {
  type        = string
  description = "Shape of bastion VM instances"
  default     = "VM.Standard2.1"
}

variable "bastion_instance_image_id" {
  type = string
  description = "The OCID of the image to be used to create a bastion VM instance"
  default = ""
}

variable "bastion_ssh_private_key" {
  type        = string
  description = "Private ssh key for existing bastion instance"
  default     = ""
}

variable "is_bastion_with_reserved_public_ip" {
  default     = false
  description = "Creates reserved public ip for bastion instance. Applicable only for new bastion, not for existing"
}