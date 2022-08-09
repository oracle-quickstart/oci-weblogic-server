
variable "subnet_ids" {
  type        = list(any)
  description = "The list of OCIDs of subnets for the backened servers"
}

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

variable "add_load_balancer" {
  type        = bool
  description = "Set to true of a load balancer was created as part of the WebLogic for OCI stack"
}

variable "lb_backendset_name" {
  default     = "wls-lb-backendset"
  description = "A friendly name for the backend set"
}

variable "lb_policy" {
  default     = "ROUND_ROBIN"
  description = "The load balancer policy for the backend set"
}

variable "is_idcs_selected" {
  type        = bool
  description = "Indicates that idcs has to be provisioned"
}

variable "idcs_cloudgate_port" {
  type        = string
  description = "Value for idcs cloud gate port"
}

variable "lb_certificate_name" {
  type        = string
  default     = "demo_cert"
  description = "A friendly name for the certificate bundle"
}

variable "allow_manual_domain_extension" {
  type        = bool
  description = "Set to true to indicate that the domain will not be automatically extended for managed servers, meaning that users have to manually extend the domain in the compute instance"
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
