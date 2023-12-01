# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {

  validators_msg_map = {
    #Dummy map to trigger an error in case we detect a validation error.
  }
  is_std_flex_shape                  = var.instance_shape.instanceShape == "VM.Standard.E3.Flex" || var.instance_shape.instanceShape == "VM.Standard.E4.Flex" || var.instance_shape.instanceShape == "VM.Standard3.Flex"
  invalid_ocpu_count_standard_shape  = local.is_std_flex_shape ? (var.instance_shape.ocpus < 1 || var.instance_shape.ocpus > 64) : var.instance_shape.instanceShape == "VM.Standard.E5.Flex" ? (var.instance_shape.ocpus < 1 || var.instance_shape.ocpus > 94) : false
  is_optimized_flex_shape            = var.instance_shape.instanceShape == "VM.Optimized3.Flex"
  invalid_ocpu_count_optimized_shape = local.is_optimized_flex_shape ? (var.instance_shape.ocpus < 1 || var.instance_shape.ocpus > 18) : false

  #Flex shape validations
  invalid_standard_flex_shape_ocpus_msg = "WLSC-ERROR: The standard flex instance shapes [ VM.Standard.E3.Flex, VM.Standard.E4.Flex, VM.Standard3.Flex ] support maximum 64 ocpus and VM.Standard.E5.Flex supports a maximum of 94 ocpus."
  validate_standard_flex_shape_ocpus    = local.invalid_ocpu_count_standard_shape ? local.validators_msg_map[local.invalid_standard_flex_shape_ocpus_msg] : null

  invalid_optimized_flex_shape_ocpus_msg = "WLSC-ERROR: The VM.Optimized3.Flex instance shape supports maximum 18 ocpus."
  validate_optimized_flex_shape_ocpus    = local.invalid_ocpu_count_optimized_shape ? local.validators_msg_map[local.invalid_optimized_flex_shape_ocpus_msg] : null
}
