locals {
  home_region      = lookup(data.oci_identity_regions.home-region.regions[0], "name")
}

data "oci_identity_regions" "home-region" {
  filter {
    name   = "key"
    values = [data.oci_identity_tenancy.tenancy.home_region_key]
  }
}

data "oci_identity_tenancy" "tenancy" {
  #Required
  tenancy_id = var.tenancy_id
}

variable "user_id" {
}

variable "fingerprint" {
}

variable "private_key_path" {
}



provider "oci" {
  tenancy_ocid     = var.tenancy_id
  user_ocid        = var.user_id
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

provider "oci" {
  alias                = "home"
  region               = local.home_region
  tenancy_ocid         = var.tenancy_id
  user_ocid            = var.user_id
  fingerprint          = var.fingerprint
  private_key_path     = var.private_key_path
  disable_auto_retries = true
}

