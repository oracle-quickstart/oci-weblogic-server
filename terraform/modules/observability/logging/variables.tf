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

variable "unified_agent_configuration_service_configuration_configuration_type" {
  type        = string
  description = "Type of Unified Agent service configuration"
  default     = "LOGGING"
}

variable "log_log_type" {
  type        = string
  description = "The logType that the log object is for, whether custom or service"
  default     = "CUSTOM"
}

variable "unified_agent_configuration_service_configuration_source_type" {
  type        = string
  description = "Unified schema logging source type"
  default     = "LOG_TAIL"
}

variable "unified_agent_configuration_service_configuration_parser_type" {
  type        = string
  description = "Type of fluent parser"
  default     = "NONE"
}

variable "oci_managed_instances_principal_group" {
  type        = string
  description = "The OCID of the dynamic group created for the WebLogic VMs"
}

variable "create_policies" {
  type        = bool
  description = "Set to true to create OCI IAM policies and dynamic groups required by the WebLogic for OCI stack"
}

variable "use_oci_logging" {
  type        = bool
  description = "Enable logging service integration for WebLogic instances"
}

variable "dynamic_group_ocid" {
  type        = string
  description = "The dynamic group that contains the WebLogic instances from which logs will be exported to OCI Logging Service"
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

variable "log_group_id" {
  type        = string
  description = "The OCID of the Log group"
}
