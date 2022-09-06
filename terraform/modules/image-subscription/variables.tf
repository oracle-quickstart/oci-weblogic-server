# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "compartment_id" {
  type        = string
  description = "The OCID of the compartment where the image exists"
}

variable "mp_listing_id" {
  type = string
  description = "marketplace listing id"
}

variable "mp_listing_resource_version" {
  type = string
  description = "marketplace listing resource version"
}
