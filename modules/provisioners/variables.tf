variable "ssh_private_key" {
  type = string
  description = "The ssh private key that will be used to allow the opc user to ssh to the compute instance"
}

variable "host_ips" {
  type = list(any)
  description = "The list of ip addresses that will be connected using opc user"
}

variable "num_vm_instances" {
  type        = string
  description = "The number of compute instances that are available"
}

variable "mode" {
  type        = string
  description = "Select mode for development(DEV) or production(PROD). In development mode, local VM scripts zip is seeded on WLS VMs "
  default     = "PROD"
  validation {
    condition     = contains(["DEV", "PROD"], var.mode)
    error_message = "Allowed values for mode are DEV and PROD."
  }
}

variable "bastion_host" {
  type        = string
  description = "The bastion ip address that will be used to connect to compute instance using opc user"
  default = ""
}

variable "bastion_host_private_key" {
  type = string
  description = "The ssh private key that will be used to allow the opc user to ssh to the bastion instance"
  default = ""
}

#TODO: Check if this variable is really needed.
variable "assign_public_ip" {
  type    = bool
  description = "Set to true if you want the compute instance to have a public IP in addition to the private ip. Use with caution"
  default = true
}

variable "is_bastion_instance_required" {
  type    = bool
  description = "Whether bastion instance is required to connect to the compute instance"
  default = true
}

variable "existing_bastion_instance_id" {
  type = string
  description = "An OCID of the existing bastion instance to connect to the compute instance"
}

variable "wlsoci_vmscripts_zip_bundle_path" {
  type = string
  description = "Absolute path to the wlsoci vmscripts zip bundle that is generated by the build"
  default = ""
}
