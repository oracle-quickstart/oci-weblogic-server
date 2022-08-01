terraform {
  required_version = ">= 1.1.2, < 1.2.0"
  required_providers {
    oci = {
      source  = "hashicorp/oci"
      version = "4.83.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.1"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
  }
}