# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "compartment_id" {
  type        = string
  description = "The OCID of the compartment where the logging service integration resources will be created"
}

variable "service_prefix_name" {
  type        = string
  description = "Prefix for stack resources"
}

variable "tags" {
  type = object({
    defined_tags  = map(any),
    freeform_tags = map(any)
  })
  description = "Defined tags and freeform tags to be added to the logging service integration resources"
  default = {
    defined_tags  = {},
    freeform_tags = {}
  }
}