# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "is_idcs_selected" {
  type        = bool
  description = "Indicates that Oracle Identity Cloud Service (IDCS) is used to authenticate user. If not selected, WebLogic Server uses the local identity store."
}

variable "idcs_host" {
  type        = string
  description = "The domain name for the host that you use to access Identity Cloud Service"
}

variable "idcs_port" {
  type        = number
  description = "The port number that you use to access Identity Cloud Service"
}

variable "idcs_tenant" {
  type        = string
  description = "The ID of your Identity Cloud Service tenant, which typically has the format idcs-<guid>, and is part of the host name that you use to access Identity Cloud Service"
}

variable "idcs_client_id" {
  type        = string
  description = "The client ID of a confidential application in Identity Cloud Service that is used to create the necessary artifacts in Identity Cloud Service. This application needs to be configured as client, and has to be granted with access to Identity Cloud Service Admin APIs, with Identity Domain Administrator app role."
}

variable "idcs_client_secret_id" {
  type        = string
  description = "The OCID of the vault secret containing the confidential application password in IDCS"
}

variable "idcs_cloudgate_port" {
  type        = number
  description = "The listen port for the Identity Cloud Service App Gateway, which authenticates requests and redirects them to WebLogic Server"
}

variable "idcs_app_prefix" {
  type        = string
  description = "This is the prefix added to the name of the confidential and enterprise applications created in IDCS during stack provisioning"
}

variable "idcs_artifacts_file" {
  type        = string
  description = "Path to the file to store information of the IDCS applications created during provisioning. Used in scenarios like scale out, among others."
  default     = "/u01/data/.idcs_artifacts.txt"
}

variable "idcs_conf_app_info_file" {
  type        = string
  description = "Path to the file to store information of IDCS confidential application created during provisioning. Used when configuring WebLogic authenticator during provisioning."
  default     = "/tmp/.idcs_conf_app_info.txt"
}

variable "idcs_ent_app_info_file" {
  type        = string
  description = "Path to the file to store information of IDCS enterprise application created during provisioning"
  default     = "/tmp/.idcs_ent_app_info.txt"
}

variable "idcs_cloudgate_info_file" {
  type        = string
  description = "Path to the file to store information of IDCS cloudgate created during provisioning."
  default     = "/tmp/.idcs_cloudgate_info.txt"
}

variable "idcs_cloudgate_config_file" {
  type        = string
  description = "Path to the file to store information about the IDCS enterprise application used by the IDCS cloudgate container"
  default     = "/u01/data/cloudgate_config/appgateway-env"
}

variable "idcs_cloudgate_docker_image_tar" {
  type        = string
  description = "Path of the binary file with the container image to run IDCS cloudgate container in the WebLogic VM"
  default     = "/u01/zips/jcs/app_gateway_docker/25.1.03/app-gateway-docker-image.tar.gz"
}

variable "idcs_cloudgate_docker_image_version" {
  type        = string
  description = "Version of the container image to run IDCS cloudgate container in the WebLogic VM"
  default     = "25.1.03-2501230623"
}

variable "idcs_cloudgate_docker_image_name" {
  type        = string
  description = "Name of the container image to run IDCS cloudgate container in the WebLogic VM"
  default     = "idcs-appgateway-docker_linux_x86_64"
}

variable "lbip" {
  type        = string
  description = "Load balancer IP. Added to the IDCS applications created during provisioning."
}