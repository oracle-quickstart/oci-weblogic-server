# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "instance_private_ips" {
  type        = list(any)
  description = "The list of private IP addresses of the instances for the backened servers"
}

variable "lb_port" {
  type        = string
  description = "Load Balancer backened port"
}

variable "health_check_url" {
  type        = string
  description = "Load Balancer health check URL path"
}

variable "lb_protocol" {
  default     = "HTTP"
  description = "The protocol the health check must use"
}

variable "lb_https_lstr_port" {
  default     = "443"
  description = "The communication port for the listener"
}

variable "num_vm_instances" {
  type        = string
  description = "The number of compute instances that are available"
}

variable "return_code" {
  default     = "404"
  description = "The status code a healthy backend server should return"
}

variable "policy_weight" {
  default     = "1"
  description = "The load balancing policy weight assigned to the server"
}

variable "lb_backendset_name" {
  default     = "wls-lb-backendset"
  description = "A friendly name for the backend set"
}

variable "lb_policy" {
  default     = "ROUND_ROBIN"
  description = "The load balancer policy for the backend set"
}

variable "lb_certificate_name" {
  type        = string
  default     = "demo_cert"
  description = "A friendly name for the certificate bundle"
}

variable "load_balancer_id" {
  type        = string
  description = "The OCID of the load balancer that was created as part of the WebLogic for OCI stack"
}

variable "use_existing_lb" {
  type        = bool
  description = "Flag to indicate to use existing load balancer"
  default     = false
}

variable "resource_name_prefix" {
  type        = string
  description = "Prefix used by the WebLogic for OCI instance of which this compute is part"
}
