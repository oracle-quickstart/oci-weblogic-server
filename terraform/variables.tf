# Copyright (c) 2023,2024, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "tenancy_ocid" {
  type        = string
  description = "The OCID of the tenancy where the WebLogic for OCI stack will be created"
}

variable "region" {
  type        = string
  description = "The region where the WebLogic for OCI stack will be created"
}

variable "compartment_ocid" {
  type        = string
  description = "The OCID of the compartment where new resources for the the WebLogic for OCI stack will be created"
}

variable "service_name" {
  type        = string
  description = "This value will be used as prefix for several resources"
}

variable "ssh_public_key" {
  type        = string
  description = "Public key for ssh access to WebLogic compute instances. Use the corresponding private key to access the WebLogic compute instances"
}

variable "create_policies" {
  type        = bool
  description = "Set to true to create OCI IAM policies and dynamic groups required by the WebLogic for OCI stack. If this is set to false, the policies and dynamic groups need to be created manually"
  default     = true
}

variable "generate_dg_tag" {
  type        = bool
  description = "Set to true to generate defined tags for dynamic group definition."
  default     = true
}

# Variable used in UI only
variable "create_service_tag" {
  type        = bool
  description = "Set to true if you want to add tags to all resources that support tag created by the WebLogic for OCI stack"
  default     = false
}

variable "service_tags" {
  type = object({
    freeformTags = map(any)
    definedTags  = map(any)
  })
  description = "Tags to be applied to all resources that support tag created by the WebLogic for OCI stack"
  default     = { freeformTags = {}, definedTags = {} }
}
# TODO: delete these two vars when UI uses control with flex shape
variable "instance_shape" {
  type        = string
  description = "The OCI VM shape for WebLogic VM instances"
  default     = "VM.Standard.E4.Flex"
}

variable "wls_ocpu_count" {
  type        = number
  description = "OCPU count for Weblogic instance"
  default     = 1
}

variable "mode" {
  type        = string
  description = "Mode of provisioning. Accepted values: PROD, DEV"
  default     = "PROD"
  validation {
    condition     = contains(["PROD", "DEV"], var.mode)
    error_message = "WLSC-ERROR: Allowed values for mode are PROD, DEV."
  }
}

variable "wlsoci_vmscripts_zip_bundle_path" {
  type        = string
  description = "Absolute path to the wlsoci vmscripts zip bundle that is generated by the build"
  default     = ""
}

# TODO: uncomment this when UI uses control with flex shape
#variable "instance_shape" {
#  type        = map(string)
#  description = "The OCI VM shape for WebLogic VM instances"
#  default = {
#    "instanceShape" = "VM.Standard.E4.Flex",
#    "ocpus"         = "1",
#    "memory"        = "16"
#  }
#}

variable "image_mode" {
  type        = string
  description = "Type of image used for provisioning. Image type must be BYOL or UCM"
  default     = "Oracle WebLogic Server BYOL Image"
}

variable "terms_and_conditions" {
  type        = bool
  description = "Terms and conditions for user to accept Oracle WebLogic Server Enterprise Edition UCM or Oracle WebLogic Suite UCM license agreement"
  default     = false
}

variable "log_level" {
  type        = string
  description = "The level of messages to be written to the provisioning logs. Allowed values: INFO, DEBUG"
  default     = "INFO"
  validation {
    condition     = contains(["INFO", "DEBUG"], var.log_level)
    error_message = "WLSC-ERROR: Allowed values for log_level are INFO, DEBUG."
  }
}

variable "tf_script_version" {
  type        = string
  description = "The version of the provisioning scripts located in the OCI image used to create the WebLogic compute instances"
  default     = ""
}

variable "is_rms_private_endpoint_required" {
  type        = bool
  description = "Set resource manager private endpoint. Default value is true"
  default     = true
}

variable "add_rms_private_endpoint" {
  type        = string
  description = "Add existing resource manager private endpoint"
  default     = "Use Existing Resource Manager Endpoint"
}

variable "rms_existing_private_endpoint_id" {
  type        = string
  description = "The OCID for the existing resource manager private endpoint"
  default     = ""
}
