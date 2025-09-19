# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_version = "~> 1.5.7"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 7.18.0"
    }
    random = {
      version = "~> 3.7.2"
    }
    template = {
      version = "~> 2.2.0"
    }
    tls = {
      version = "~> 4.1.0"
    }
    time = {
      version = "~> 0.13.1"
    }
    null = {
      version = "~> 3.2.4"
    }
  }
}
