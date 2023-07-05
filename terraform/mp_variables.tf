# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.


variable "use_bastion_marketplace_image" {
  type        = bool
  description = "Set to true if using a marketplace bastion image, to create the marketplace subscriptions"
  default     = true
}

variable "bastion_image_id" {
  type        = string
  description = "The OCID of the marketplace bastion image"
  default     = "ocid1.image.oc1..aaaaaaaablqmvpn633emdv7o2k42km6nxjt4i44aqwab3wxwquyz3ag6hvmq"
}

variable "bastion_listing_id" {
  type        = string
  description = "The OCID of the marketplace bastion image listing"
  default     = "ocid1.appcataloglisting.oc1..aaaaaaaacicjx6jviqczqow567tadr5ju7iy2m4vx6opyra6thql55n2nnvq"
}

variable "bastion_listing_resource_version" {
  type        = string
  description = "The OCID of the marketplace bastion image listing resource version"
  default     = "23.2.3-ol8.7-23.04.25-230702-1"
}

variable "use_marketplace_image" {
  type        = bool
  description = "Set to true if using a marketplace WebLogic instance image, to create the marketplace subscriptions"
  default     = true
}

variable "instance_image_id" {
  type        = string
  description = "The OCID of the compute image used to create the WebLogic compute instances"
  default     = ""
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
