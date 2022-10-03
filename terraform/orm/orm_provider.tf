# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

provider "oci" {
  region           = var.region
}

provider "oci" {
  alias                = "home"
  region               = local.home_region
  disable_auto_retries = true
}

