terraform {
  required_version = ">= 1.1.2, < 1.2.0"
  required_providers {
    oci = {
      source = "hashicorp/oci"
      version = "4.83.0"
    }
    template = {
      source = "hashicorp/template"
    }
  }
}