# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {

  empty_free_form_tags = {
    for key, value in var.tags.freeform_tags : key => value
    if trimspace(key) == "" || trimspace(value) == ""
  }

  empty_defined_tags = {
    for key, value in var.tags.defined_tags : key => value
    if trimspace(value) == ""
  }

  size_check_freeform_tags = {
    for key, value in var.tags.freeform_tags : key => value
    if length(trimspace(key)) > 100 || length(trimspace(value)) > 256
  }

  size_check_defined_tags = {
    for key, value in var.tags.defined_tags : key => value
    if length(trimspace(value)) > 256
  }

  empty_defined_tag_msg      = "WLSC-ERROR: The value for defined tag is required."
  validate_empty_defined_tag = length(local.empty_defined_tags) != 0 ? local.validators_msg_map[local.empty_defined_tag_msg] : null

  size_check_freeform_tags_msg = "WLSC-ERROR: The freefrom tag's key size should not exceed 100 characters and the value should not exceed 256 characters"
  validate_freeform_tag_size   = length(local.size_check_freeform_tags) != 0 ? local.validators_msg_map[local.size_check_freeform_tags_msg] : null

  size_check_defined_tags_msg = "WLSC-ERROR: The defined tag's value should not exceed 256 characters"
  validate_defined_tag_size   = length(local.size_check_defined_tags) != 0 ? local.validators_msg_map[local.size_check_defined_tags_msg] : null

  set_dev_defined_tag          = var.create_policies && !var.generate_dg_tag && length(var.service_tags.definedTags) == 0
  set_dev_defined_tag_msg      = "WLSC-ERROR: At least one defined tag is required if generate_dg_tag is false or mode is DEV."
  validate_set_dev_defined_tag = local.set_dev_defined_tag ? local.validators_msg_map[local.set_dev_defined_tag_msg] : null

}
