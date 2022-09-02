# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  
  #If APM service is selected, validate the APM domain ID
  invalid_apm_domain_id = var.use_apm_service ? length(regexall("^ocid1.apmdomain.", var.apm_domain_id)) == 0 : false
  apm_domain_id_msg = "WLSC-ERROR: The value for Application Performance Monitoring (APM) domain id [apm_domain_id] is not valid. The value must begin with ocid1 followed by resource type, e.g. ocid1.apmdomain."
  validate_apm_domain_id = local.invalid_apm_domain_id ? local.validators_msg_map[local.apm_domain_id_msg] : null

  #Private data key name should not be blank
  apm_private_data_key_name_msg = "WLSC-ERROR: The value for private data key name [apm_private_data_key_name] is not valid. The value must not be blank"
  validate_private_data_key_name = (var.use_apm_service && trimspace(var.apm_private_data_key_name) == "") ? local.validators_msg_map[local.apm_private_data_key_name_msg] : null
}
