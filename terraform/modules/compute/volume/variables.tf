# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "bv_params" {
  type = map(object({
    ad             = string
    compartment_id = string
    display_name   = string
    bv_size        = number
    defined_tags   = map(string)
    freeform_tags  = map(string)
  }))
  description = "A map with variables used to create a block volume. A volume will be created for each element in the map"
  default     = {}
}

variable "bv_attach_params" {
  type = map(object({
    display_name    = string
    attachment_type = string
    instance_id     = string
    volume_id       = string
  }))
  description = "A map with variables used to create a block volume attachment. A volume attachment will be created for each element in the map"
  default     = {}
}

