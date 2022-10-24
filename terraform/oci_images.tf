variable "marketplace_source_images" {
  type = map(object({
    ocid = string
    is_pricing_associated = bool
    compatible_shapes = set(string)
  }))
  default = {
    main_mktpl_image = {
      ocid = ""
      is_pricing_associated = true
      compatible_shapes = []
    }
    ucm_image = {
      ocid = ""
      is_pricing_associated = true
      compatible_shapes = []
    }
    baselinux_instance_image = {
      ocid = "ocid1.image.oc1..aaaaaaaaamleur4y63beitm7dmf4pu63x3n6h7v6g5ohzfw4mkbspawalraa"
      is_pricing_associated = false
      compatible_shapes = []
    }
  }
}
