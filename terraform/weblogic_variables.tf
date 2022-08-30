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
  description = "Name of WebLogic administration user"
  default     = "weblogic"
  validation {
    condition     = replace(var.wls_admin_user, "/^[a-zA-Z][a-zA-Z0-9]{7,127}/", "0") == "0"
    error_message = "The value for wls_admin_user provided should be alphanumeric and length should be between 8 and 128 characters."
  }
}

variable "wls_admin_password_id" {
  type        = string
  description = "The OCID of the vault secret with the password for WebLogic administration user"
  validation {
    condition     = length(regexall("^ocid1.vaultsecret.", var.wls_admin_password_id)) > 0
    error_message = "The value for wls_admin_password_id should start with \"ocid1.vaultsecret.\"."
  }
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

variable "wls_expose_admin_port" {
  type        = bool
  description = "[WARNING] Selecting this option will expose the console to the internet if the default 0.0.0.0/0 CIDR is used. You should change the CIDR range below to allow access to a trusted IP range."
  default     = false
}

variable "wls_admin_port_source_cidr" {
  type        = string
  description = "Create a security list to allow access to the WebLogic Administration Console port to the source CIDR range. [WARNING] Keeping the default 0.0.0.0/0 CIDR will expose the console to the internet. You should change the CIDR range to allow access to a trusted IP range."
  default     = "0.0.0.0/0"
}

variable "wls_server_startup_args" {
  type        = string
  description = "The startup arguments to be added to the managed servers of the domain"
  default     = ""
}

variable "wls_extern_ssl_admin_port" {
  type        = number
  description = "The administration server SSL port on which to access the administration console"
  default     = 7002
  validation {
    condition     = var.wls_extern_ssl_admin_port > 0
    error_message = "The value for wls_extern_ssl_admin_port should be greater than 0."
  }
}

variable "wls_ms_extern_port" {
  type        = number
  description = "The managed server port on which to send application traffic"
  default     = 7003
  validation {
    condition     = var.wls_ms_extern_port > 0
    error_message = "The value for wls_ms_extern_port should be greater than 0."
  }
}

variable "wls_ms_extern_ssl_port" {
  type        = number
  description = "The managed server SSL port on which to send application traffic"
  default     = 7004
  validation {
    condition     = var.wls_ms_extern_ssl_port > 0
    error_message = "The value for wls_ms_extern_ssl_port should be greater than 0."
  }
}

# Port for channel Extern on Admin Server
variable "wls_extern_admin_port" {
  type        = number
  description = "Weblogic console port"
  default     = 7001
  validation {
    condition     = var.wls_extern_admin_port > 0
    error_message = "The value for wls_extern_admin_port should be greater than 0."
  }
}

variable "deploy_sample_app" {
  type        = bool
  description = "Set to true to install a sample application in the WebLogic domain"
  default     = true
}