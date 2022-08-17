# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "wls_version" {
  type        = string
  description = "The WebLogic version to be installed for this stack. Accepted values are: 12.2.1.4, 14.1.1.0"
  default     = "12.2.1.4"
  validation {
    condition     = contains(["12.2.1.4", "14.1.1.0"], var.wls_version)
    error_message = "Allowed values for wls_version are 12.2.1.4, 14.1.1.0."
  }
}

variable "wls_edition" {
  type        = string
  description = "The WebLogic edition to be installed in this compute instance. Accepted values are: SE, SUITE, EE"
  default     = "EE"
  validation {
    condition     = contains(["EE", "SE", "SUITE"], var.wls_edition)
    error_message = "Allowed values for wls_edition are SE, EE and SUITE."
  }
}

variable "wls_node_count" {
  type        = number
  description = "Number of WebLogic managed servers. One VM per managed server will be created"
  default     = "1"
}

variable "wls_admin_user" {
  type        = string
  default     = "weblogic"
  description = "Name of WebLogic administration user"
}

variable "wls_admin_password_id" {
  type        = string
  description = "The OCID of the vault secret with the password for WebLogic administration user"
}


variable "wls_14c_jdk_version" {
  type        = string
  description = "JDK version to use when installing WebLogic 14c. Ignored when WebLogic version is not 14c. Allowed values: jdk8, jdk11"
  default     = "jdk8"
  validation {
    condition     = contains(["jdk8", "jdk11"], var.wls_14c_jdk_version)
    error_message = "Allowed values for wls_14c_jdk_version are jdk8, jdk11."
  }
}


variable "wls_server_startup_args" {
  type        = string
  description = "The startup arguments to be added to the managed servers of the domain"
  default     = ""
}

variable "wls_extern_ssl_admin_port" {
  type        = number
  default     = 7002
  description = "The administration server SSL port on which to access the administration console"
}

variable "wls_ms_extern_port" {
  type        = number
  description = "The managed server port on which to send application traffic"
  default     = 7003
}

variable "wls_ms_extern_ssl_port" {
  type        = string
  default     = "7004"
  description = "The managed server SSL port on which to send application traffic"
}

variable "deploy_sample_app" {
  type        = bool
  description = "Set to true to install a sample application in the WebLogic domain"
  default     = true
}
