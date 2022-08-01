locals {
  ocpus = length(regexall("^.*Flex", var.instance_shape)) > 0 ? var.ocpu_count : lookup(data.oci_core_shapes.oci_shapes.shapes[0], "ocpus")
}