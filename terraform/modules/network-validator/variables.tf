# Copyright (c) 2022, 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "wls_subnet_id" {
  type        = string
  description = "The OCID of the subnet where WebLogic VMs will be created"
}

variable "bastion_subnet_id" {
  type        = string
  description = "The OCID of the subnet for the bastion instance"
}

variable "lb_subnet_1_id" {
  type        = string
  description = "The OCID of a regional or AD-specific subnet for primary load balancer"
}
