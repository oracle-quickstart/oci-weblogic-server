# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  validation_script_wls_subnet_param = var.wls_subnet_id != "" ? format("--wlssubnet %s", var.wls_subnet_id) : ""
}