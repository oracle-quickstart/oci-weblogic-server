# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "marketplace_source_images" {
  type = map(object({
    ocid                  = string
    is_pricing_associated = bool
    compatible_shapes     = set(string)
  }))
  default = {
    main_mktpl_image = {
      ocid                  = ""
      is_pricing_associated = true
      compatible_shapes     = []
    }
    ucm_image = {
      ocid                  = ""
      is_pricing_associated = true
      compatible_shapes     = []
    }
    baselinux_instance_image = {
      ocid                  = "ocid1.image.oc1..aaaaaaaablqmvpn633emdv7o2k42km6nxjt4i44aqwab3wxwquyz3ag6hvmq"
      is_pricing_associated = false
      compatible_shapes     = []
    }
  }
}
