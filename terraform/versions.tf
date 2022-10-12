# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_version = ">= 1.1.2, < 1.2.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "4.96.0"
    }
    random = {
      version = "3.3.2"
    }
    template = {
      version = "2.2.0"
    }
    tls = {
      version = "4.0.1"
    }
    time = {
      version = "0.7.2"
    }
    null = {
      version = "3.1.1"
    }
  }

}
