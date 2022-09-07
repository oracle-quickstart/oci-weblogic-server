# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.


variable "use_bastion_marketplace_image" {
  type        = bool
  description = "Set to true to use marketplace image for bastion instance. Set to false to provide your own image using bastion_image_id"
  default     = true
}

variable "bastion_image_id" {
  type        = string
  description = "The OCID of the marketplace bastion image"
  default     = ""
}

variable "bastion_listing_id" {
  type        = string
  description = "The OCID of the marketplace bastion image listing"
  default     = ""
}

variable "bastion_listing_resource_version" {
  type        = string
  description = "The OCID of the marketplace bastion image listing resource version"
  default     = ""
}

variable "use_marketplace_image" {
  type        = bool
  description = "Set to true if the image subscription is used for provisioning"
  default     = true
}

variable "instance_image_id" {
  type        = string
  description = "The OCID of the compute image used to create the WebLogic compute instances"
}

variable "listing_id" {
  type        = string
  description = "The OCID of the marketplace admin image listing"
  default     = ""
}

variable "listing_resource_version" {
  type        = string
  description = "The OCID of the marketplace admin image listing resource version"
  default     = ""
}

variable "ucm_instance_image_id" {
  type        = string
  description = "The OCID of the marketplace admin image which is used for provisioning"
  default     = ""
}

variable "ucm_listing_id" {
  type        = string
  description = "The OCID of the marketplace admin image listing"
  default     = ""
}

variable "ucm_listing_resource_version" {
  type        = string
  description = "The OCID of the marketplace admin image listing resource version"
  default     = ""
}
