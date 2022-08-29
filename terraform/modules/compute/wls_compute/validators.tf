# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {

  validators_msg_map = {
    #Dummy map to trigger an error in case we detect a validation error.
  }

  invalid_ocpu_count_standard_shape  = (var.wls_ocpu_count < 1) || (var.wls_ocpu_count > 64)
  invalid_ocpu_count_optimized_shape = (var.wls_ocpu_count < 1) || (var.wls_ocpu_count > 18)

  #Flex shape validations
  invalid_standard_flex_shape_ocpus_msg  = "WLSC-ERROR: The standard flex instance shape [ VM.Standard.E3.Flex, VM.Standard.E4.Flex, VM.Standard3.Flex ] support maximum 64 ocpus."
  validate_standard_flex_shape_ocpus = local.invalid_ocpu_count_standard_shape && (var.instance_shape == "VM.Standard.E3.Flex" || var.instance_shape == "VM.Standard.E4.Flex" || var.instance_shape == "VM.Standard3.Flex") ? local.validators_msg_map[local.invalid_standard_flex_shape_ocpus_msg] : null

  invalid_optimized_flex_shape_ocpus_msg  = "WLSC-ERROR: The VM.Optimized3.Flex instance shape supports maximum 18 ocpus."
  validate_optimized_flex_shape_ocpus = local.invalid_ocpu_count_optimized_shape && (var.instance_shape == "VM.Optimized3.Flex") ? local.validators_msg_map[local.invalid_optimized_flex_shape_ocpus_msg] : null

}