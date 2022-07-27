variable "wls_edition" {
  default = "EE"
}

variable "wls_admin_user" {
  type = string
  description = "The name of the admin user that will be added to the WebLogic domain"
}
variable "wls_domain_name" {
  type = string
}
variable "wls_admin_server_name" {
  type = string
}
variable "wls_admin_password" {
  type = string
}

variable "wls_extern_admin_port" {
  default = "7001"
}
variable "wls_extern_ssl_admin_port" {
  default = "7002"
}
variable "provisioning_timeout_mins" {
  default = 30
}
variable "wls_admin_server_wait_timeout_mins" {
  default = 30
}
variable "wls_admin_port" {
  default = "9071"
}
variable "wls_admin_ssl_port" {
  default = "9072"
}
variable "wls_nm_port" {
  default = "5556"
}
variable "wls_provisioning_timeout" {
  default = "10"
}
variable "wls_cluster_name" {
  default = "jcsoci_cluster"
}
variable "wls_ms_port" {
  default = "9074"
}
variable "wls_ms_extern_port" {
  default = "7003"
}
variable "wls_ms_extern_ssl_port" {
  default = "9073"
}
variable "wls_ms_ssl_port" {
  default = "7004"
}
variable "wls_server_startup_args" {
  type = string
}
variable "wls_ms_server_name" {
  default = "jcsoci_server_"
}
variable "wls_cluster_mc_port" {
  default = "5555"
}
variable "wls_machine_name" {
  default = "jcsoci_machine_"
}

variable "wls_version" {}

variable "wls_14c_jdk_version" {
  type = string
  description = "JDK version to use when installing WebLogic 14c. Ignored when WebLogic version is not 14c. Allowed values: jdk8, jdk11"
}
/**
 * Defines the mapping between wls_version and corresponding FMW zip.
 */
variable "wls_version_to_fmw_map" {
  type = map

  default = {
    "12.2.1.3" = "/u01/zips/jcs/FMW/12.2.1.3.0/fmiddleware.zip"
    "12.2.1.4" = "/u01/zips/jcs/FMW/12.2.1.4.0/fmiddleware.zip"
    "14.1.1.0" = "/u01/zips/jcs/FMW/14.1.1.0.0/fmiddleware.zip"
  }
}

/**
 * Defines the mapping between wls_version and corresponding JDK zip.
 */
variable "wls_version_to_jdk_map" {
  type = map

  default = {
    "12.2.1.3" = "/u01/zips/jcs/JDK8.0/jdk.zip"
    "12.2.1.4" = "/u01/zips/jcs/JDK8.0/jdk.zip"
  }
}

/**
 * Defines the mapping between jdk version and corresponding JDK zip.
 */
variable "wls_14c_to_jdk_map" {
  type = map

  default = {
    "jdk8" = "/u01/zips/jcs/JDK8.0/jdk.zip"
    "jdk11" = "/u01/zips/jcs/JDK11.0/jdk.zip"
  }
}
variable "wls_version_to_rcu_component_list_map" {
  type = map

  default = {
    "12.2.1.3" = "MDS,WLS,STB,IAU_APPEND,IAU_VIEWER,UCSUMS,IAU,OPSS"
    "12.2.1.4" = "MDS,WLS,STB,IAU_APPEND,IAU_VIEWER,UCSUMS,IAU,OPSS"
  }
}
