# Copyright (c) 2023, Oracle and/or its affiliates.
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
  default     = "/u01/zips/jcs/APM-AGENT/1.7.2733/apm-java-agent-installer.jar"
}

variable "apm_agent_path" {
  type        = string
  description = "Directory where the APM Java Agent will be installed"
  default     = "/u01/APM"
}

variable "ocir_user" {
  type        = string
  description = "User for Oracle Cloud Infrastructure Registry login"
  default     = ""
}

variable "ocir_url" {
  type        = string
  description = "URL for Oracle Cloud Infrastructure Registry"
  default     = ""
}

variable "ocir_auth_token_id" {
  type        = string
  description = "Secrets Oracle Cloud ID (OCID) for Oracle Cloud Infrastructure Registry authorization token"
  default     = ""
}

variable "fn_application_id" {
  type        = string
  description = "The OCID of the function application"
}

variable "fn_repo_path" {
  type        = string
  description = "The path of the function repository"
}

variable "use_autoscaling" {
  type        = bool
  description = "Indicating that autoscaling is enabled"
  default     = false
}

variable "scalein_notification_topic_id" {
  type        = string
  description = "The OCID of the notification topic for scale in operation"
}

variable "scaleout_notification_topic_id" {
  type        = string
  description = "The OCID of the notification topic for scale out operation"
}
variable "profile_ocid"{
  type        = string
  description = "The OCID of the created profile"
}
variable "enable_osmh"{
  type        = bool
  description = "Indicating that OSMH is enabled"
}
