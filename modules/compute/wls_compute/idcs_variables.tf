# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "is_idcs_selected" {
  type = bool
  description = "Indicates that Oracle Identity Cloud Service has to be provisioned"
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

variable "idcs_app_prefix" {}

variable "idcs_artifacts_file" {
  default = "/u01/data/.idcs_artifacts.txt"
}

variable "idcs_conf_app_info_file" {
  default = "/tmp/.idcs_conf_app_info.txt"
}

variable "idcs_ent_app_info_file" {
  default = "/tmp/.idcs_ent_app_info.txt"
}

variable "idcs_cloudgate_info_file" {
  default = "/tmp/.idcs_cloudgate_info.txt"
}

variable "idcs_cloudgate_config_file" {
  default = "/u01/data/cloudgate_config/appgateway-env"
}

variable "idcs_cloudgate_docker_image_tar" {
  default = "/u01/zips/jcs/app_gateway_docker/21.2.2/app-gateway-docker-image.tar.gz"
}

variable "idcs_cloudgate_docker_image_version" {
  default = "21.2.2-2105050509"
}

variable "idcs_cloudgate_docker_image_name" {
  default = "idcs/idcs-appgateway"
}

variable "lbip" {}

variable "is_idcs_internal" {
  default = "false"
}

variable "is_idcs_untrusted" {
  type    = bool
  default = false
}

variable "idcs_ip" {
  default = ""
}