variable "wls_edition" {
  type        = string
  description = "The WebLogic edition to be installed in this compute instance. Accepted values are: SE, SUITE, EE"
  default     = "EE"
  validation {
    condition     = contains(["EE", "SE", "SUITE"], var.wls_edition)
    error_message = "Allowed values for wls_edition are SE, EE and SUITE."
  }
}
variable "wls_admin_user" {
  type        = string
  description = "The name of the admin user that will be added to the WebLogic domain"
}
variable "wls_admin_password_id" {
  type        = string
  description = "The OCID of the vault secret containing the password for the WebLogic administration user"
}
variable "wls_domain_name" {
  type        = string
  description = "The name of the WebLogic domain to be created"
}
variable "wls_cluster_name" {
  type        = string
  description = "The name of the cluster to be created in the WebLogig domain"
  default     = "wlsoci_cluster"
}
variable "wls_admin_server_name" {
  type        = string
  description = "The name of the administration user to be added to the WebLogic domain"
}
variable "wls_ms_server_name" {
  type        = string
  description = "The prefix of the name of the managed servers in the domain. A number will be appended to this prefix to form the final name of the server"
  default     = "wlsoci_server_"
}
variable "wls_machine_name" {
  type        = string
  description = "The prefix of the name of the machines in the domain. A number will be appended to this prefix to form the final name of the machine"
  default     = "wlsoci_machine_"
}
variable "wls_extern_admin_port" {
  type        = number
  description = "The administration server port on which to access the administration console"
  default     = 7001
}
variable "wls_extern_ssl_admin_port" {
  type        = number
  description = "The administration server SSL port on which to access the administration console"
  default     = 7002
}
variable "wls_ms_extern_port" {
  type        = number
  description = "The managed server port on which to send application traffic"
  default     = 7003
}
variable "wls_ms_extern_ssl_port" {
  type        = number
  description = "The managed server SSL port on which to send application traffic"
  default     = 7004
}
variable "wls_admin_port" {
  type        = number
  description = "The administration server port for T3 protocol"
  default     = 9071
}
variable "wls_admin_ssl_port" {
  type        = number
  description = "The administration server port for T3s protocol"
  default     = 9072
}
variable "wls_ms_port" {
  type        = number
  description = "The managed server port for T3 protocol"
  default     = 9073
}
variable "wls_ms_ssl_port" {
  type        = number
  description = "The managed server port for T3s protocol"
  default     = 9074
}
variable "wls_cluster_mc_port" {
  type        = number
  description = "The managed server port on which to send heartbeats and other internal cluster traffic"
  default     = 5555
}
variable "wls_nm_port" {
  type        = number
  description = "The listen port number for the node manager process on all compute instances"
  default     = 5556
}
variable "wls_server_startup_args" {
  type        = string
  description = "The startup arguments to be added to the managed servers of the domain"
}
variable "provisioning_timeout_mins" {
  type        = number
  description = "The timeout in minutes for the compute instance creation"
  default     = 30
}
variable "wls_admin_server_wait_timeout_mins" {
  type        = number
  description = "Teh timeout in minutes for the administration server to enroll to node manager"
  default     = 30
}
variable "wls_version" {
  type        = string
  description = "The WebLogic version to be installed in this instance. Accepted values are: 12.2.1.4, 14.1.1.0"
  validation {
    condition     = contains(["12.2.1.4", "14.1.1.0"], var.wls_version)
    error_message = "Allowed values for wls_version are 12.2.1.4, 14.1.1.0."
  }
}
variable "wls_14c_jdk_version" {
  type        = string
  description = "JDK version to use when installing WebLogic 14c. Ignored when WebLogic version is not 14c. Allowed values: jdk8, jdk11"
  validation {
    condition     = var.wls_14c_jdk_version == "" || contains(["jdk8", "jdk11"], var.wls_14c_jdk_version)
    error_message = "Allowed values for wls_14c_jdk_version are jdk8, jdk11."
  }
}
variable "wls_version_to_fmw_map" {
  type        = map(string)
  description = "Defines the mapping between wls_version and corresponding FMW zip"
  default = {
    "12.2.1.3" = "/u01/zips/jcs/FMW/12.2.1.3.0/fmiddleware.zip"
    "12.2.1.4" = "/u01/zips/jcs/FMW/12.2.1.4.0/fmiddleware.zip"
    "14.1.1.0" = "/u01/zips/jcs/FMW/14.1.1.0.0/fmiddleware.zip"
  }
}
variable "wls_version_to_jdk_map" {
  type        = map(string)
  description = "Defines the mapping between wls_version and corresponding JDK zip."
  default = {
    "12.2.1.3" = "/u01/zips/jcs/JDK8.0/jdk.zip"
    "12.2.1.4" = "/u01/zips/jcs/JDK8.0/jdk.zip"
  }
}
variable "wls_14c_to_jdk_map" {
  type        = map(string)
  description = "Defines the mapping between jdk version and corresponding JDK zip."
  default = {
    "jdk8"  = "/u01/zips/jcs/JDK8.0/jdk.zip"
    "jdk11" = "/u01/zips/jcs/JDK11.0/jdk.zip"
  }
}
variable "wls_version_to_rcu_component_list_map" {
  type        = map(string)
  description = "Defines the mapping between wls_version version and corresponding RCU components."
  default = {
    "12.2.1.3" = "MDS,WLS,STB,IAU_APPEND,IAU_VIEWER,UCSUMS,IAU,OPSS"
    "12.2.1.4" = "MDS,WLS,STB,IAU_APPEND,IAU_VIEWER,UCSUMS,IAU,OPSS"
  }
}
