variable "display_name" {
  description = "The display name for the profile"
  type        = string
}

variable "profile_type" {
  description = "The type of the profile (e.g., SOFTWARESOURCE)"
  type        = string
  default     = "SOFTWARESOURCE"
}

variable "arch_type" {
  description = "The architecture type of the profile"
  type        = string
  default     = "X86_64"
}

variable "description" {
  description = "A description for the profile"
  type        = string
  default     = ""
}

variable "os_family" {
  description = "The operating system family for the profile (e.g., LINUX, WINDOWS)"
  type        = string
  default     = "ORACLE_LINUX_8"

}

variable "registration_type" {
  description = "The registration type for the profile"
  type        = string
  default     = "OCI_LINUX"
}

variable "software_source_ids" {
  description = "List of software source IDs associated with the profile"
  type        = list(string)
  default     = []
}

variable "vendor_name" {
  description = "The vendor name for the profile"
  type        = string
  default     = "ORACLE"
}

variable "compartment_id" {
  description = "The OCID of the compartment where the profile will be created"
  type        = string
}

variable "is_default_profile" {
  description = "Indicates whether this profile is the default profile"
  type        = bool
  default     = false
}
variable "tenancy_id" {
  description = "The OCID of the tenancy"
  type        = string
}
variable "software_availabilty" {
  description = "Availability at OCI for the software sources"
  type        = string
  default     = "SELECTED"
}
