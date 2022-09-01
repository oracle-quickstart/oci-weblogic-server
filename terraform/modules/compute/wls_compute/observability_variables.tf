# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

#Logging attributes
variable "log_group_id" {
  type        = string
  description = "The OCID of the Log group"
}

variable "use_oci_logging" {
  type        = bool
  description = "Enable logging service integration for WebLogic instances"
}

#APM attributes
variable "use_apm_service" {
  type        = bool
  description = "Indicates if Application Performance Monitoring integration is enabled"
}

variable "apm_domain_compartment_id" {
  type        = string
  description = "The OCID of the compartment of the APM domain"
}

variable "apm_domain_id" {
  type        = string
  description = "The OCID of the Application Performance Monitoring domain used by WebLogic instances"
}

variable "apm_private_data_key_name" {
  type        = string
  description = "The name of the private data key used by this instance to push metrics to the Application Performance Monitoring domain"
}

variable "apm_agent_installer_path" {
  type        = string
  description = "Absolute path of the APM Java Agent installer jar file"
  default     = "/u01/zips/jcs/APM-AGENT/1.3.1940/apm-java-agent-installer.jar"
}

variable "apm_agent_path" {
  type        = string
  description = "The APM Java Agent will be installed under this directory"
  default     = "/u01/APM"
}
