# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "tenancy_id" {
  type        = string
  description = "The OCID of the tenancy where the dynamic group and policy will be created"
  validation {
    condition     = length(regexall("^ocid1.tenancy.*$", var.tenancy_id)) > 0
    error_message = "WLSC-ERROR: The value for tenancy_id should start with \"ocid1.tenancy.\"."
  }
}

variable "compartment_id" {
  type        = string
  description = "The OCID of the compartment for the matching rule of dynamic group"
  validation {
    condition     = length(regexall("^ocid1.compartment.*$", var.compartment_id)) > 0
    error_message = "WLSC-ERROR: The value for compartment_id should start with \"ocid1.compartment.\"."
  }
}

variable "network_compartment_id" {
  type        = string
  description = "The OCID of the compartment where the network resources like VCN are located"
  validation {
    condition     = length(regexall("^ocid1.compartment.*$", var.network_compartment_id)) > 0
    error_message = "WLSC-ERROR: The value for network_compartment_id should start with \"ocid1.compartment.\"."
  }
}

variable "fss_compartment_id" {
  type        = string
  description = "The OCID of the compartment where the file system exists"
  validation {
    condition     = length(regexall("^ocid1.compartment.*$", var.fss_compartment_id)) > 0
    error_message = "WLSC-ERROR: The value for fss_compartment_id should start with \"ocid1.compartment.\"."
  }
}

variable "mount_target_compartment_id" {
  type        = string
  description = "The OCID of the compartment where the mount target exists"
  validation {
    condition     = length(regexall("^ocid1.compartment.*$", var.mount_target_compartment_id)) > 0
    error_message = "WLSC-ERROR: The value for mount_target_compartment_id should start with \"ocid1.compartment.\"."
  }
}

variable "vcn_id" {
  type        = string
  description = "The OCID of the VCN where the WebLogic VMs are located"
  validation {
    condition     = var.vcn_id == "" || length(regexall("^ocid1.vcn.*$", var.vcn_id)) > 0
    error_message = "WLSC-ERROR: The value for vcn_id should be blank or start with \"ocid1.vcn.\"."
  }
}

variable "wls_existing_vcn_id" {
  type        = string
  description = "The OCID of the VCN where the WebLogic VMs are located. Should be blank if the VCN is created with the stack."
  validation {
    condition     = var.wls_existing_vcn_id == "" || length(regexall("^ocid1.vcn.*$", var.wls_existing_vcn_id)) > 0
    error_message = "WLSC-ERROR: The value for wls_existing_vcn_id should be blank or start with \"ocid1.vcn.\"."
  }
}

variable "resource_name_prefix" {
  type        = string
  description = "Prefix used to name resources created by this module"
  validation {
    condition     = var.resource_name_prefix != ""
    error_message = "WLSC-ERROR: The value for resource_name_prefix cannot be empty."
  }
}

variable "tags" {
  type = object({
    defined_tags  = map(any),
    freeform_tags = map(any)
  })
  description = "Defined tags and freeform tags to be added to the policy"
  default = {
    defined_tags  = {},
    freeform_tags = {}
  }
}

variable "dynamic_group_rule" {
  type        = string
  description = "Value of the tag to be used to identify resources that should be included in the dynamic groups for the policies"
}

variable "wls_admin_password_id" {
  type        = string
  description = "The OCID of the vault secret containing the password for the WebLogic administration user"
}

variable "atp_db" {
  type = object({
    is_atp                        = bool
    password_id                   = string
    compartment_id                = string
    is_atp_with_private_endpoints = bool
    network_compartment_id        = string
    existing_vcn_id               = string
    existing_vcn_add_seclist      = bool
  })
  description = <<-EOT
  atp_db = {
    is_atp: "Indicates if an ATP database is used to store the schemas of a JRF WebLogic domain"
    password_id: "The OCID of the vault secret with the password of the database"
    compartment_id: "The OCID of the compartment where the ATP database is located"
    is_atp_with_private_endpoints: "Indicates if the ATP database uses private endpoint for network access"
    network_compartment_id: "The OCID of the compartment in which the ATP database private endpoint VCN is found"
    existing_vcn_id: "The OCID of the VCN used by the ATP database private endpoint"
    existing_vcn_add_seclist: "Set to true to add a security list to the network security group (for ATP with private endpoint) that allows connections from the WebLogic Server subnet"
  }
  EOT
}

variable "oci_db" {
  type = object({
    is_oci_db                = bool
    password_id              = string
    compartment_id           = string
    network_compartment_id   = string
    existing_vcn_id          = string
    oci_db_connection_string = string
    existing_vcn_add_seclist = bool
  })
  description = <<-EOT
  oci_db = {
    is_oci_db: "Indicates if an OCI database is used to store the schemas of a JRF WebLogic domain"
    password_id: "The OCID of the vault secret with the password of the database"
    compartment_id: "The OCID of the compartment where the OCI database is located"
    network_compartment_id: "The OCID of the compartment in which the DB System VCN is found"
    existing_vcn_id: "The OCID of the DB system VCN"
    existing_vcn_add_seclist: "Set to true to add a security list to the database subnet (for OCI DB) that allows connections from the WebLogic Server subnet"
  }
  EOT
}

variable "is_idcs_selected" {
  type        = bool
  description = "Indicates that Oracle Identity Cloud Service (IDCS) is used to authenticate user. If not selected, WebLogic Server uses the local identity store."
}

variable "idcs_client_secret_id" {
  type        = string
  description = "The OCID of the vault secret containing the confidential application password in IDCS"
}

variable "use_oci_logging" {
  type        = bool
  description = "Enable logging service integration for WebLogic instances"
}

variable "use_apm_service" {
  type        = bool
  description = "Indicates if Application Performance Monitoring integration is enabled"
}

variable "apm_domain_compartment_id" {
  type        = string
  description = "The OCID of the compartment of the APM domain"
}

variable "add_fss" {
  type        = bool
  description = "Add file system storage to WebLogic Server instances"
  default     = false
}

variable "use_autoscaling" {
  type        = bool
  description = "Indicating that autoscaling is enabled"
  default     = false
}

variable "ocir_auth_token_id" {
  type        = string
  description = "Secrets Oracle Cloud ID (OCID) for Oracle Cloud Infrastructure Registry authorization token"
}

variable "add_load_balancer" {
  type        = bool
  description = "If this variable is true and existing_load_balancer is blank, a new load balancer will be created for the stack. If existing_load_balancer_id is not blank, the specified load balancer will be used"
  default     = false
}

variable "is_rms_private_endpoint_required" {
  type        = bool
  description = "Set resource manager private endpoint"
}
