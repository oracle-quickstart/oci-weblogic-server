# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "instance_private_ips" {
  type        = list(any)
  description = "The list of private IP addresses of the instances for the backend servers"
}

variable "backend_port" {
  type        = number
  description = "Port for backends in the load balancer"
}

variable "health_check_url" {
  type        = string
  description = "Load balancer health check URL path"
}

variable "lb_protocol" {
  type        = string
  description = "The protocol used by the health check and the listener"
  default     = "HTTP"
}

variable "lb_https_lstr_port" {
  type        = number
  description = "The communication port for the HTTPS listener"
  default     = 443
}

variable "num_vm_instances" {
  type        = string
  description = "The number of compute instances that must be added to the backend set"
}

variable "return_code" {
  type        = number
  description = "The HTTP status code a healthy backend server should return"
  default     = "404"
}

variable "policy_weight" {
  type        = number
  description = "The load balancing policy weight assigned to the server"
  default     = 1
}

variable "lb_backendset_name" {
  type        = string
  description = "A friendly name for the backend set"
  default     = "wls-lb-backendset"
}

variable "lb_policy" {
  type        = string
  description = "The load balancer policy for the backend set"
  default     = "ROUND_ROBIN"
}

variable "lb_certificate_name" {
  type        = string
  description = "A friendly name for the certificate bundle"
  default     = "demo_cert"
}

variable "load_balancer_id" {
  type        = string
  description = "The OCID of the load balancer that was created as part of the WebLogic for OCI stack, or a load balancer created manually"
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
