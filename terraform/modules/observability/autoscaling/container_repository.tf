# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_artifacts_container_repository" "wlsc_autoscaling_function_repo_scaleout" {

  #Required
  compartment_id = var.tenancy_id
  display_name   = format("%s/scaleout", var.fn_repo_name)
}

resource "oci_artifacts_container_repository" "wlsc_autoscaling_function_repo_scalein" {

  #Required
  compartment_id = var.tenancy_id
  display_name   = format("%s/scalein", var.fn_repo_name)
}

resource "oci_artifacts_container_repository" "wlsc_autoscaling_function_repo_orm_job_completion_handler" {

  #Required
  compartment_id = var.tenancy_id
  display_name   = format("%s/orm_job_completion_handler", var.fn_repo_name)
}
