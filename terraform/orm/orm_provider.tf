# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

provider "oci" {
  version = "4.96.0"
  region           = var.region
}
provider "oci" {
  version = "4.96.0"
  alias                = "home"
  region               = local.home_region
  disable_auto_retries = true
}
provider "tls" {
  version = "~>4.0.3"
}
provider "null" {
  version = "~>3.1.1"
}
provider "random" {
  version = "~>3.4.3"
}
provider "template" {
  version = "~>2.2.0"
}
provider "time" {
  version = "~>0.9.0"
}
