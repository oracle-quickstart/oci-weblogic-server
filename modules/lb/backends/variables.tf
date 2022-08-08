
variable "subnet_ids" {
  type        = list
  description = "The list of OCIDs of subnets for the backened servers"
}

variable "instance_private_ips" {
  type        = list
  description = "The list of private ipaddresses of the instances for the backened servers"
}

variable "name" {
  default     = "wls-loadbalancer"
  description = "The name of the backend set to add the backend server to"
}

variable "wls_ms_port" {
  type        = string
  description = "weblogic managed server port"
}

variable "lb-protocol" {
  default     = "HTTP"
  description = "The protocol the health check must use"
}

variable "lb-https-lstr-port" {
  default     = "443"
  description = "The communication port for the listener"
}

variable "numVMInstances" {
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
  type = bool
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

variable "lbCount" {
  type        = number
  description = "Set to 1 if add load balancer is set to true"
}

variable "allow_manual_domain_extension" {
  type        = bool
  description = "Set to true to indicate that the domain will not be automatically extended for managed servers, meaning that users have to manually extend the domain in the compute instance"
}

variable "load_balancer_id" {
  type = string
  description = "The OCID of the load balancer that was created as part of the WebLogic for OCI stack"
}

variable "use_existing_lb" {
  type = bool
  description = "Flag to indicate to use existing load balancer"
  default = false
}

variable "service_name_prefix" {
  type = string
  description = "Prefix used by the WebLogic for OCI instance of which this compute is part"
}