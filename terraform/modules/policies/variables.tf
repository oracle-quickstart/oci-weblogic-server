# Copyright (c) 2022, Oracle and/or its affiliates.
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

variable "vcn_id" {
  type        = string
  description = "The OCID of the VCN where the WebLogic VMs are located"
  validation {
    condition     = length(regexall("^ocid1.vcn.*$", var.vcn_id)) > 0
    error_message = "WLSC-ERROR: The value for vcn_id should start with \"ocid1.vcn.\"."
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
    is_atp         = bool
    compartment_id = string
    password_id    = string
  })
  description = <<-EOT
  atp_db = {
    is_atp: "Indicates if an ATP database is used to store the schemas of a JRF WebLogic domain"
    compartment_id: "The OCID of the compartment where the ATP database is located"
    password_id: "The OCID of the vault secret with the password of the database"
  }
  EOT
}

variable "oci_db" {
  type = object({
    password_id              = string
    network_compartment_id   = string
    existing_vcn_id          = string
    existing_vcn_add_seclist = bool
  })
  description = <<-EOT
  oci_db = {
    password_id: "The OCID of the vault secret with the password of the database"
    network_compartment_id: "The OCID of the compartment in which the DB System VCN is found"
    existing_vcn_id: "The OCID of the DB system VCN"
    existing_vcn_add_seclist: "Set to true to add a security list to the database subnet (for OCI DB) when using existing VCN that allows connections from the WebLogic Server subnet"
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