# Copyright (c) 2023, 2026, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.


variable "use_bastion_marketplace_image" {
  type        = bool
  description = "Set to true if using a marketplace bastion image, to create the marketplace subscriptions"
  default     = true
}

variable "bastion_image_id" {
  type        = string
  description = "The OCID of the marketplace bastion image"
  default     = "ocid1.image.oc1..aaaaaaaah35eqhck2m5gyqcts6g3ey7bzu4f5sww5kqjltofumt464cxpfua"
}

variable "bastion_listing_id" {
  type        = string
  description = "The OCID of the marketplace bastion image listing"
  default     = "ocid1.appcataloglisting.oc1..aaaaaaaacicjx6jviqczqow567tadr5ju7iy2m4vx6opyra6thql55n2nnvq"
}

variable "bastion_listing_resource_version" {
  type        = string
  description = "The OCID of the marketplace bastion image listing resource version"
  default     = "26.3.2-ol8.10-26.01.29-260818-1"
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
