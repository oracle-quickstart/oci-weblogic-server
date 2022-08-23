# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "is_idcs_selected" {
  type = bool
  description = "Indicates that idcs has to be provisioned"
}

variable "idcs_host" {
  type        = string
  description = "Value for idcs host"
}

variable "idcs_port" {
  type        = number
  description = "Value for idcs port"
}

variable "idcs_tenant" {
  type        = string
  description = "Value for idcs tenant"
}

variable "idcs_client_id" {
  type        = string
  description = "Value for idcs client id"
}

variable "idcs_client_secret_id" {
  type        = string
  description = "The OCID of the vault secret containing the password of the idcs client secret"
}

variable "idcs_cloudgate_port" {
  type        = number
  description = "Value for idcs cloud gate port"
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