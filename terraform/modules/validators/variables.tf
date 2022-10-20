# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "service_name" {
  type        = string
  description = "Prefix for stack resources"
}

variable "wls_ms_port" {
  type        = number
  description = "The managed server port for T3 protocol"
}

variable "wls_ms_ssl_port" {
  type        = number
  description = "The managed server port for T3s protocol"
}

variable "wls_extern_admin_port" {
  type        = number
  description = "The administration server port on which to access the administration console"
}

variable "wls_extern_ssl_admin_port" {
  type        = number
  description = "The administration server SSL port on which to access the administration console"
}

variable "wls_admin_port_source_cidr" {
  type        = string
  description = "Create a security list to allow access to the WebLogic Administration Console port to the source CIDR range. [WARNING] Keeping the default 0.0.0.0/0 CIDR will expose the console to the internet. You should change the CIDR range to allow access to a trusted IP range."
}

variable "wls_expose_admin_port" {
  type        = bool
  description = "[WARNING] Selecting this option will expose the console to the internet if the default 0.0.0.0/0 CIDR is used. You should change the CIDR range below to allow access to a trusted IP range."
}

variable "wls_subnet_cidr" {
  type        = string
  description = "CIDR for weblogic subnet"
}

variable "is_bastion_instance_required" {
  type        = bool
  description = "Set to true to use a bastion, either new or existing. If existing_bastion_instance_id is blank, a new bastion will be created"
}

variable "bastion_subnet_cidr" {
  type        = string
  description = "CIDR for bastion subnet"
}

variable "existing_bastion_instance_id" {
  type        = string
  description = "The OCID of a compute instance that will work as bastion"
}

variable "lb_subnet_1_cidr" {
  type        = string
  description = "CIDR for loadbalancer subnet"
}

variable "network_compartment_id" {
  type        = string
  description = "The OCID of the compartment for network resources. Leave it blank to use the the same compartment for both compute and network resources"
}

variable "existing_vcn_id" {
  type        = string
  description = "The OCID of the existing VCN where the WebLogic servers and other resources will be created. If not specified, a new VCN is created"
}

variable "is_idcs_selected" {
  type        = bool
  description = "Indicates that Oracle Identity Cloud Service (IDCS) is used to authenticate user. If not selected, WebLogic Server uses the local identity store."
}

variable "idcs_host" {
  type        = string
  description = "The domain name for the host that you use to access Identity Cloud Service"
}

variable "idcs_tenant" {
  type        = string
  description = "The ID of your Identity Cloud Service tenant, which typically has the format idcs-<guid>, and is part of the host name that you use to access Identity Cloud Service"
}

variable "idcs_client_id" {
  type        = string
  description = "The client ID of a confidential application in Identity Cloud Service that is used to create the necessary artifacts in Identity Cloud Service. This application needs to be configured as client, and has to be granted with access to Identity Cloud Service Admin APIs, with Identity Domain Administrator app role."
}

variable "idcs_client_secret_id" {
  type        = string
  description = "The OCID of the vault secret containing the confidential application password in IDCS"
}

variable "idcs_cloudgate_port" {
  type        = number
  description = "The listen port for the Identity Cloud Service App Gateway, which authenticates requests and redirects them to WebLogic Server"
}

variable "wls_subnet_id" {
  type        = string
  description = "The OCID of the subnet for the WebLogic instances. Leave it blank if a new subnet will be created by the stack"
}

variable "add_load_balancer" {
  type        = bool
  description = "If this variable is true and existing_load_balancer is blank, a new load balancer will be created for the stack. If existing_load_balancer_id is not blank, the specified load balancer will be used"
}

variable "existing_load_balancer_id" {
  type        = string
  description = "The OCID of an existing load balancer. If set, use the existing load balancer and add the stack nodes to the backend set of the existing load balancer. Set add_load_balancer to true in order for this value to take effect"
}

variable "existing_lb_subnet_1_id" {
  type        = string
  description = "The OCID of a regional or AD-specific subnet for existing primary load balancer"
}
variable "existing_lb_subnet_2_id" {
  type        = string
  description = "The OCID of an AD-specific subnet for existing secondary load balancer. Must be blank if the load balancer is in a regional subnet or is private"
}

variable "backendset_name_for_existing_load_balancer" {
  type        = string
  description = "The name of an existing backend set in an existing load balancer. The backend set should not have any backend. The WebLogic VMs will be added as backends to this backend set"
}

variable "existing_load_balancer_found" {
  type        = bool
  description = "True if the load balancer specified in [existing_load_balancer_id] exists"
}

variable "lb_subnet_1_id" {
  type        = string
  description = "The OCID of a regional or AD-specific subnet for primary load balancer"
}

variable "lb_subnet_2_id" {
  type        = string
  description = "The OCID of a regional or AD-specific subnet for secondary load balancer"
}

variable "wls_version" {
  type        = string
  description = "The WebLogic version to be installed for this stack. Accepted values are: 12.2.1.4, 14.1.1.0"
  validation {
    condition     = contains(["12.2.1.4", "14.1.1.0"], var.wls_version)
    error_message = "WLSC-ERROR: Allowed values for wls_version are 12.2.1.4, 14.1.1.0."
  }
}

variable "assign_public_ip" {
  type        = bool
  description = "Set to true if the WebLogic compute instances will be created in a public subnet and should have a public IP"
}
// Common DB params
variable "db_user" {
  type        = string
  description = "The user that will connect to the database to create the JRF schemas"
}
variable "db_password_id" {
  type        = string
  description = "The OCID of the vault secret with the password of the database"
}

variable "is_vcn_peering" {
  type        = bool
  description = "Set to true if automatic VCN peering will be done during stack creation"
}

variable "db_vcn_lpg_id" {
  type        = string
  description = "The OCID of the Local Peering Gateway (LPG) in the DB VCN to which the LPG in the WebLogic VCN will be peered. Required for VCN peering"
  validation {
    condition     = var.db_vcn_lpg_id == "" || length(regexall("^ocid1.localpeeringgateway.*$", var.db_vcn_lpg_id)) > 0
    error_message = "WLSC-ERROR: The value for db_vcn_lpg_id should be blank or start with \"ocid1.localpeeringgateway.\"."
  }
}

# OCI DB parameters
variable "is_oci_db" {
  type        = bool
  description = "Set to true if JRF with OCI DB is used"
}
variable "oci_db_connection_string" {
  type        = string
  description = "Connection string to connect to the OCI database. Example: //<scan_hostname>.<host_domain_name>:<db_port>/<pdb_or_sid>.<Host Domain Name>. Specify either the connection string or the OCID of the DB"
}
variable "oci_db_compartment_id" {
  type        = string
  description = "The OCID of the compartment where the OCI database is located, if JRF with OCI DB is used"
  validation {
    condition     = var.oci_db_compartment_id == "" || length(regexall("^ocid1.compartment.*$", var.oci_db_compartment_id)) > 0
    error_message = "WLSC-ERROR: The value for oci_db_compartment_id should be blank or start with \"ocid1.compartment.\"."
  }
}
variable "db_network_compartment_id" {
  type        = string
  description = "The OCID of the compartment in which the DB VCN is found"
}
variable "oci_db_existing_vcn_id" {
  type        = string
  description = "The OCID of the VCN of the OCI database, if JRF with OCI DB is used"
  validation {
    condition     = var.oci_db_existing_vcn_id == "" || length(regexall("^ocid1.vcn.*$", var.oci_db_existing_vcn_id)) > 0
    error_message = "WLSC-ERROR: The value for oci_db_existing_vcn_id should be blank or start with \"ocid1.vcn.\"."
  }
}
variable "oci_db_dbsystem_id" {
  type        = string
  description = "The OCID of the db system of the OCI database, if JRF with OCI DB is used"
  validation {
    condition     = var.oci_db_dbsystem_id == "" || length(regexall("^ocid1.dbsystem.*$", var.oci_db_dbsystem_id)) > 0
    error_message = "WLSC-ERROR: The value for oci_db_dbsystem_id should be blank or start with \"ocid1.dbsystem.\"."
  }
}
variable "oci_db_database_id" {
  type        = string
  description = "The OCID of the database, if JRF with OCI DB is used"
  validation {
    condition     = var.oci_db_database_id == "" || length(regexall("^ocid1.database.*$", var.oci_db_database_id)) > 0
    error_message = "WLSC-ERROR: The value for oci_db_database_id should be blank or start with \"ocid1.database.\"."
  }
}
variable "oci_db_pdb_service_name" {
  type        = string
  description = "The name of the pluggable database (PDB). Required for Oracle Database 12c or later"
}
variable "bastion_subnet_id" {
  type        = string
  description = "The OCID of the subnet for the bastion instance"
}

variable "use_regional_subnet" {
  type        = bool
  description = "Indicates use of regional subnets (preferred) instead of AD specific subnets"
}

variable "vcn_name" {
  type        = string
  description = "Name of new virtual cloud network"
}

variable "bastion_ssh_private_key" {
  type        = string
  description = "Private ssh key for existing bastion instance"
}

variable "is_lb_private" {
  type        = bool
  description = "Indicates use of private load balancer"
}

# ATP parameters
variable "is_atp_db" {
  type        = bool
  description = "Set to true if a JRF with ATP DB is used"
}

variable "atp_db_id" {
  type        = string
  description = "The OCID of the ATP database, if JRF with ATP is used"
  validation {
    condition     = var.atp_db_id == "" || length(regexall("^ocid1.autonomousdatabase.*$", var.atp_db_id)) > 0
    error_message = "WLSC-ERROR: The value for atp_db_id should be blank or start with \"ocid1.autonomousdatabase.\"."
  }
}
variable "atp_db_compartment_id" {
  type        = string
  description = "The OCID of the compartment where the ATP database is located, if JRF with ATP is used"
  validation {
    condition     = var.atp_db_compartment_id == "" || length(regexall("^ocid1.compartment.*$", var.atp_db_compartment_id)) > 0
    error_message = "WLSC-ERROR: The value for atp_db_compartment_id should be blank or start with \"ocid1.compartment.\"."
  }
}

variable "atp_db_level" {
  type        = string
  description = "The ATP database level. Allowed values are [low, tp, tpurgent]"
  validation {
    condition     = contains(["low", "tp", "tpurgent"], var.atp_db_level)
    error_message = "WLSC-ERROR: Invalid value for atp_db_level. Allowed values are low, tp and tpurgent."
  }
}

variable "is_atp_with_private_endpoints" {
  type        = bool
  description = "Set to true if the ATP DB uses private endpoint for access control."
}

variable "atp_db_existing_vcn_id" {
  type        = string
  description = "The OCID of the VCN of the ATP DB when using private endpoint."
  validation {
    condition     = var.atp_db_existing_vcn_id == "" || length(regexall("^ocid1.vcn.*$", var.atp_db_existing_vcn_id)) > 0
    error_message = "WLSC-ERROR: The value for atp_db_existing_vcn_id should be blank or start with \"ocid1.vcn.\"."
  }
}

variable "add_fss" {
  type        = bool
  description = "Add file system storage to WebLogic Server instances"
}

variable "fss_availability_domain" {
  type        = string
  description = "The name of the availability domain where the file system and mount target exists"
}

variable "existing_fss_id" {
  type        = string
  description = "The OCID of your existing file system"
  validation {
    condition     = var.existing_fss_id == "" || length(regexall("^ocid1.filesystem.*$", var.existing_fss_id)) > 0
    error_message = "WLSC-ERROR: The value for existing_fss_id should be blank or start with \"ocid1.filesystem.\"."
  }
}

variable "mount_target_subnet_id" {
  type        = string
  description = "The OCID of the subnet where the mount target exists"
  validation {
    condition     = var.mount_target_subnet_id == "" || length(regexall("^ocid1.subnet.*$", var.mount_target_subnet_id)) > 0
    error_message = "WLSC-ERROR: The value for mount_target_subnet_id should be blank or start with \"ocid1.subnet.\"."
  }
}

variable "mount_target_id" {
  type        = string
  description = "The OCID of the mount target for File Shared System"
  validation {
    condition     = var.mount_target_id == "" || length(regexall("^ocid1.mounttarget.*$", var.mount_target_id)) > 0
    error_message = "WLSC-ERROR: The value for mount_target_id should be blank or start with \"ocid1.mounttarget.\"."
  }
}

variable "mount_target_compartment_id" {
  type        = string
  description = "The OCID of the compartment where the mount target exists"
  validation {
    condition     = var.mount_target_compartment_id == "" || length(regexall("^ocid1.compartment.*$", var.mount_target_compartment_id)) > 0
    error_message = "WLSC-ERROR: The value for mount_target_compartment_id should be blank or start with \"ocid1.compartment.\"."
  }
}

variable "mount_target_subnet_cidr" {
  type        = string
  description = "CIDR value of  the subnet to be used for FSS mount target"
}

variable "mount_target_availability_domain" {
  type        = string
  description = "The name of the availability domain where the mount target exists"
}

variable "create_policies" {
  type        = bool
  description = "Set to true to create OCI IAM policies and dynamic groups required by the WebLogic for OCI stack"
}

variable "use_oci_logging" {
  type        = bool
  description = "Enable logging service integration for WebLogic instances"
}

variable "dynamic_group_id" {
  type        = string
  description = "The dynamic group that contains the WebLogic instances from which logs will be exported to OCI Logging Service"
}

variable "use_apm_service" {
  type        = bool
  description = "Indicates if Application Performance Monitoring integration is enabled"
}

variable "apm_domain_id" {
  type        = string
  description = "The OCID of the Application Performance Monitoring domain used by WebLogic instances"
}

variable "apm_private_data_key_name" {
  type        = string
  description = "The name of the private data key used by this instance to push metrics to the Application Performance Monitoring domain"
}

variable "use_autoscaling" {
  type        = bool
  description = "Indicating that autoscaling is enabled"
}

variable "wls_metric" {
  type        = string
  description = "Metric to use for triggering scaling actions"
}

variable "min_threshold_percent" {
  type        = number
  description = "Minimum threshold in percentage for the metric"
}

variable "max_threshold_percent" {
  type        = number
  description = "Maximum threshold in percentage for the metric"
}

variable "min_threshold_counter" {
  type        = number
  description = "Minimum threshold count for the metric"
}

variable "max_threshold_counter" {
  type        = number
  description = "Maximum threshold count for the metric"
}

variable "ocir_auth_token_id" {
  type        = string
  description = "Secrets Oracle Cloud ID (OCID) for Oracle Cloud Infrastructure Registry authorization token"
}

variable "use_existing_subnets" {
  type        = bool
  description = "Set to true if the existing subnets are used to create VCN config"
}

variable "tags" {
  type = object({
    defined_tags  = map(any),
    freeform_tags = map(any),
  })
  description = "Tags to be applied to all resources that support tag created by the WebLogic for OCI stack. Tags provided by user and tags generated by other modules"
}

variable "wls_node_count_limit" {
  type        = number
  description = "Maximum number of WebLogic managed servers"
}

variable "num_vm_instances" {
  type        = number
  description = "Number of WebLogic managed servers. One VM per managed server will be created"
}

variable "create_dg_tags" {
  type        = bool
  description = "Flag to create defined tags for dynamic group definition"
}

variable "service_tags" {
  type = object({
    freeformTags = map(string)
    definedTags  = map(string)
  })
  description = "Tags to be applied to all resources that support tag created by the WebLogic for OCI stack. Only tags provided by user"
}

variable "mode" {
  type        = string
  description = "Mode of provisioning. Accepted values: PROD, DEV"
}

variable "wlsoci_vmscripts_zip_bundle_path" {
  type        = string
  description = "Absolute path to the wlsoci vmscripts zip bundle that is generated by the build"
}

variable "image_mode" {
  type        = string
  description = "Type of image used for provisioning. Image type must be BYOL or UCM"
}

variable "terms_and_conditions" {
  type        = bool
  description = "Terms and conditions for user to accept Oracle WebLogic Server Enterprise Edition UCM or Oracle WebLogic Suite UCM license agreement"
}

variable "instance_image_id" {
  type        = string
  description = "The OCID of the compute image used to create the WebLogic compute instances"
}

variable "ucm_instance_image_id" {
  type        = string
  description = "The OCID of the marketplace UCM image which will be used for provisioning"
}

variable "use_marketplace_image" {
  type        = bool
  description = "Set to true if using a marketplace WebLogic instance image, to create the marketplace subscriptions"
}

variable "ucm_instance_count" {
  type        = number
  description = "Number of instances created through ucm image"
}

variable "provisioned_node_count" {
  type        = number
  description = "Number of provisioned WebLogic instances"
}

variable "wls_edition" {
  type        = string
  description = "The WebLogic edition to be installed in this compute instance. Accepted values are: SE, EE, SUITE"
}

variable "availability_domain" {
  type        = string
  description = "The name of the fss availability domain that user enters for providing existing fss id"
}
