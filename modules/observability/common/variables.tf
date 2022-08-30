# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "compartment_id" {
  type = string
}

variable "service_prefix_name" {
  type = string
}

variable "create_log_group" {
  type = bool
}

variable "defined_tags" {
  type    = map
  default = {}
}

variable "freeform_tags" {
  type    = map
  default = {}
}