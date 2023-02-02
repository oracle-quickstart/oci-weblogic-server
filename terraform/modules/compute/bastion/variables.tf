# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "tenancy_id" {
  type        = string
  description = "The OCID of the tenancy where the bastion instance will be created"
  validation {
    condition     = length(regexall("^ocid1.tenancy.*$", var.tenancy_id)) > 0
    error_message = "WLSC-ERROR: The value for tenancy_id should start with \"ocid1.tenancy.\"."
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
    error_message = "WLSC-ERROR: The value for compartment_id should start with \"ocid1.compartment.\"."
  }
}

variable "region" {
  type        = string
  description = "The region where the bastion instance will be created. Example: us-phoenix-1"
}

variable "instance_shape" {
  type        = map(string)
  description = "The map containing shape, ocpus, and memory of the bastion instance"
}

variable "instance_name" {
  type        = string
  description = "The name to be used as display_name for the bastion compute and its associated reserved public ip, if specified"
}

variable "vm_count" {
  type        = number
  description = "Number of WebLogic VM nodes in the WebLogic for OCI instance associated to this bastion"
  validation {
    condition     = var.vm_count > 0
    error_message = "WLSC-ERROR: The value for vm_count must be greater than 0."
  }
}

variable "is_bastion_with_reserved_public_ip" {
  type        = bool
  description = "Set to true if the bastion instance should be created with a new reserved public IP"
  default     = false
}

variable "bastion_subnet_id" {
  type        = string
  description = "The OCID of the subnet where the bastion compute will be created"
  validation {
    condition     = length(regexall("^ocid1.subnet.*$", var.bastion_subnet_id)) > 0
    error_message = "WLSC-ERROR: The value for bastion_subnet_id should start with \"ocid1.subnet.\"."
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
    error_message = "WLSC-ERROR: The value for instance_image_id should start with \"ocid1.image.\"."
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

variable "bastion_nsg_id" {
  type        = list(any)
  description = "The list of NSG OCIDs associated with the bastion compute"
}

variable "tags" {
  type = object({
    defined_tags  = map(any),
    freeform_tags = map(any)
  })
  description = "Defined tags and freeform tags to be added to the bastion compute instance"
  default = {
    defined_tags  = {},
    freeform_tags = {}
  }
}

variable "mp_listing_id" {
  type        = string
  description = "marketplace listing id"
}

variable "mp_listing_resource_version" {
  type        = string
  description = "marketplace listing resource version"
}

variable "use_bastion_marketplace_image" {
  type        = bool
  description = "Set to true to use marketplace image for bastion instance. Set to false to provide your own image using bastion_image_id"
  default     = true
}
