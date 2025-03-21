# Copyright (c) 2023, 2024, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "wls_version" {
  type        = string
  description = "The WebLogic version to be installed for this stack. Accepted values are: 12.2.1.4, 14.1.1.0, 14.1.2.0"
  default     = "12.2.1.4"
  validation {
    condition     = contains(["12.2.1.4", "14.1.1.0","14.1.2.0"], var.wls_version)
    error_message = "WLSC-ERROR: Allowed values for wls_version are 12.2.1.4, 14.1.1.0 & 14.1.2.0."
  }
}

variable "wls_node_count" {
  type        = number
  description = "Number of WebLogic managed servers. One VM per managed server will be created"
  default     = "1"
}

variable "wls_node_count_limit" {
  type        = number
  description = "Maximum number of WebLogic managed servers"
  default     = "8"
}


variable "wls_admin_user" {
  type        = string
  description = "Name of WebLogic administration user"
  default     = "weblogic"
  validation {
    condition     = replace(var.wls_admin_user, "/^[a-zA-Z][a-zA-Z0-9_-]{7,127}/", "0") == "0"
    error_message = "WLSC-ERROR: The value for wls_admin_user should be between 8 and 128 characters long and alphanumeric, and can contain underscore (_) and hyphen(-) special characters."
  }
}

# Variable used in UI only
variable "wls_admin_secret_compartment_id" {
  type        = string
  description = "The OCID of the compartment of the vault secret with the password for WebLogic admin user"
  default     = ""
}

variable "wls_admin_password_id" {
  type        = string
  description = "The OCID of the vault secret with the password for WebLogic administration user"
  validation {
    condition     = length(regexall("^ocid1.vaultsecret.", var.wls_admin_password_id)) > 0
    error_message = "WLSC-ERROR: The value for wls_admin_password_id should start with \"ocid1.vaultsecret.\"."
  }
}

variable "wls_14c_jdk_version" {
  type        = string
  description = "JDK version to use when installing WebLogic 14c. Ignored when WebLogic version is not 14c. Allowed values: jdk8, jdk11"
  default     = "jdk8"
  validation {
    condition     = contains(["jdk8", "jdk11"], var.wls_14c_jdk_version)
    error_message = "WLSC-ERROR: Allowed values for wls_14c_jdk_version are jdk8, jdk11."
  }
}

variable "wls_14120_jdk_version" {
  type        = string
  description = "JDK version to use when installing WebLogic 14.1.2.0 version. Ignored when WebLogic version is not 14.1.2.0. Allowed values: jdk21, jdk17"
  default     = "jdk17"
  validation {
    condition     = contains(["jdk17", "jdk21"], var.wls_14120_jdk_version)
    error_message = "WLSC-ERROR: Allowed values for wls_14120_jdk_version are jdk17, jdk21."
  }
}

# Variable used in UI only
variable "configure_wls_ports" {
  type        = bool
  description = "Configure the ports for administration server, managed server and cluster. It is optional, if not changed, default ports will be used"
  default     = false
}

variable "wls_ms_port" {
  type        = number
  description = "The managed server port for T3 protocol"
  default     = 9073
  validation {
    condition     = var.wls_ms_port > 0
    error_message = "WLSC-ERROR: The value for wls_ms_port should be greater than 0."
  }
}

variable "wls_ms_ssl_port" {
  type        = number
  description = "The managed server port for T3s protocol"
  default     = 9074
  validation {
    condition     = var.wls_ms_ssl_port > 0
    error_message = "WLSC-ERROR: The value for wls_ms_ssl_port should be greater than 0."
  }
}

variable "wls_admin_port" {
  type        = number
  description = "The administration server port for T3 protocol"
  default     = 9071
  validation {
    condition     = var.wls_admin_port > 0
    error_message = "WLSC-ERROR: The value for wls_admin_port should be greater than 0."
  }
}

variable "wls_admin_ssl_port" {
  type        = number
  description = "The administration server port for T3s protocol"
  default     = 9072
  validation {
    condition     = var.wls_admin_ssl_port > 0
    error_message = "WLSC-ERROR: The value for wls_admin_ssl_port should be greater than 0."
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
    error_message = "WLSC-ERROR: The value for wls_extern_ssl_admin_port should be greater than 0."
  }
}

variable "wls_ms_extern_port" {
  type        = number
  description = "The managed server port on which to send application traffic"
  default     = 7003
  validation {
    condition     = var.wls_ms_extern_port > 0
    error_message = "WLSC-ERROR: The value for wls_ms_extern_port should be greater than 0."
  }
}

variable "wls_ms_extern_ssl_port" {
  type        = number
  description = "The managed server SSL port on which to send application traffic"
  default     = 7004
  validation {
    condition     = var.wls_ms_extern_ssl_port > 0
    error_message = "WLSC-ERROR: The value for wls_ms_extern_ssl_port should be greater than 0."
  }
}

# Port for channel Extern on Admin Server
variable "wls_extern_admin_port" {
  type        = number
  description = "Weblogic console port"
  default     = 7001
  validation {
    condition     = var.wls_extern_admin_port > 0
    error_message = "WLSC-ERROR: The value for wls_extern_admin_port should be greater than 0."
  }
}

variable "wls_nm_port" {
  type        = number
  description = "The listen port number for the node manager process on all compute instances"
  default     = 5556
  validation {
    condition     = var.wls_nm_port > 0
    error_message = "WLSC-ERROR: The value for wls_nm_port should be greater than 0."
  }
}

variable "allow_manual_domain_extension" {
  type        = bool
  description = "If true, when new nodes are added, the domain will not be extended to include the node. You must manually add the managed servers to your domain configuration after updating the stack"
  default     = false
}

variable "deploy_sample_app" {
  type        = bool
  description = "Set to true to install a sample application in the WebLogic domain"
  default     = true
}

# All the variables under this comment belong to Secured Production Mode
variable "configure_secure_mode" {
  type        = bool
  description = "Set to true to configure a secure WebLogic domain"
}

variable "preserve_boot_properties" {
  type        = bool
  description = "Set to true to preserve the boot.properties file for administration server and managed servers"
  default     = "false"
}

variable "keystore_password_id" {
  type        = string
  description = "The OCID of the vault secret with the password for creating the keystore"
  default     = ""
}

variable "root_ca_id" {
  type        = string
  description = "The OCID of the existing root certificate authority to issue the certificates"
  default     = ""
}

variable "cert_compartment_id" {
  type        = string
  description = "The OCID of the compartment where the certificate will be created. Leave it blank to use the network compartment for the certificate"
  default     = ""
}

variable "administration_port" {
  type        = number
  description = "The domain-wide administration port to configure a secure WebLogic domain"
  default     = 9002
}

variable "ms_administration_port" {
  type        = number
  description = "The administration port for managed servers to configure a secure WebLogic domain"
  default     = 9004
}

variable "thread_pool_limit" {
  type        = number
  description = "Shared Capacity For Work Managers"
  default     = 65536
}

variable "wls_primary_admin_user" {
  type        = string
  description = "Name of primary WebLogic administration user"
  default     = "wls_user"
  validation {
    condition     = replace(var.wls_primary_admin_user, "/^[a-zA-Z][a-zA-Z0-9_-]{7,127}/", "0") == "0" && !contains(["system", "admin", "administrator", "weblogic"], var.wls_primary_admin_user)
    error_message = "WLSC-ERROR: The value for wls_primary_admin_user should be between 8 and 128 characters long and alphanumeric, and can contain underscore (_) and hyphen(-) special characters, and should not be system, admin, administrator, or weblogic."
  }
}

variable "wls_secondary_admin_user" {
  type        = string
  description = "Name of secondary WebLogic administration user"
  default     = "wls_user_1"
  validation {
    condition     = replace(var.wls_secondary_admin_user, "/^[a-zA-Z][a-zA-Z0-9_-]{7,127}/", "0") == "0" && !contains(["system", "admin", "administrator", "weblogic"], var.wls_secondary_admin_user)
    error_message = "WLSC-ERROR: The value for wls_secondary_admin_user should be between 8 and 128 characters long and alphanumeric, and can contain underscore (_) and hyphen(-) special characters, and should not be system, admin, administrator, or weblogic."
  }
}

variable "wls_secondary_admin_password_id" {
  type        = string
  description = "The OCID of the vault secret with the password for secondary WebLogic administration user"
  default     = ""
}