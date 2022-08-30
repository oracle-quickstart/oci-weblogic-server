# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "compartment_id" {
}

variable "service_prefix_name" {
}

variable "unified_agent_configuration_service_configuration_configuration_type" {
  default = "LOGGING"
}

variable "log_log_type" {
  default = "CUSTOM"
}

variable "unified_agent_configuration_service_configuration_source_type" {
  default = "LOG_TAIL"
}

variable "unified_agent_configuration_service_configuration_parser_type" {
  default = "NONE"
}

variable "oci_managed_instances_principal_group" {
}

variable "create_policies" {
  type    = bool
}

  variable "use_oci_logging" {
  type    = bool
}

variable "dynamic_group_ocid" {
  type        = string
}

variable "defined_tags" {
  type    = map
  default = {}
}

variable "freeform_tags" {
  type    = map
  default = {}
}

variable "log_group_id" {
  type = string
}
