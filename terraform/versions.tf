# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_version = ">= 1.1.2, < 1.2.0"
  required_providers {
    oci = {
      source  = "hashicorp/oci"
      version = "4.83.0"
    }
    random = {
      version = "~>3.4.3"
    }
    template = {
      version = "~>2.2.0"
    }
    tls = {
      version = "~>4.0.3"
    }
    time = {
      version = "~>0.9.0"
    }
    null = {
      version = "~>3.1.1"
    }
  }
}
