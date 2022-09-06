# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.


variable "use_baselinux_marketplace_image" {
  type        = bool
  description = "Set to true to use marketplace image for bastion instance. Set to false to provide your own image using bastion_instance_image_id"
  default     = true
}

variable "mp_baselinux_instance_image_id" {
  type        = string
  description = "The OCID of the marketplace bastion image"
  default = ""
}

variable "mp_baselinux_listing_id" {
  type = string
  description = "The OCID of the marketplace bastion image listing"
  default = ""
}

variable "mp_baselinux_listing_resource_version" {
  type = string
  description = "The OCID of the marketplace bastion image listing resource version"
  default = ""
}

variable "use_marketplace_image" {
  type    = bool
  description = "Set to true if the image subscription is used for provisioning"
  default = true
}

variable "mp_instance_image_id" {
  type = string
  description = "The OCID of the marketplace admin image which is used for provisioning"
  default = ""
}

variable "mp_listing_id" {
  type = string
  description = "The OCID of the marketplace admin image listing"
  default = ""
}

variable "mp_listing_resource_version" {
  type = string
  description = The OCID of the marketplace admin image listing resource version"
  default = ""
}

variable "mp_ucm_instance_image_id" {
  type = string
  description = "The OCID of the marketplace admin image which is used for provisioning"
  default = ""
}

variable "mp_ucm_listing_id" {
  type = string
  description = "The OCID of the marketplace admin image listing"
  default = ""
}

variable "mp_ucm_listing_resource_version" {
  type = string
  description = The OCID of the marketplace admin image listing resource version"
  default = ""
}
