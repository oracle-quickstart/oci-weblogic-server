# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_core_virtual_network" "wls_vcn" {

  cidr_block     = var.wls_vcn_cidr
  dns_label      = format("%svcn", substr((var.resource_name_prefix), 0, 10))
  compartment_id = var.compartment_id
  display_name   = "${var.resource_name_prefix}-${var.vcn_name}"

  defined_tags  = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

resource "oci_core_default_security_list" "default_security_list" {
  # Default security lists is created with all rules with VCN CIDR as source, instead of 0.0.0.0/0
  manage_default_resource_id = oci_core_virtual_network.wls_vcn.default_security_list_id
  egress_security_rules {
    description      = "Allow all outbound traffic"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
    stateless        = "false"
  }

  ingress_security_rules {
    description = ""
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol    = "1"
    source      = oci_core_virtual_network.wls_vcn.cidr_block
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }

  ingress_security_rules {
    description = ""
    icmp_options {
      type = "3"
    }
    protocol    = "1"
    source      = oci_core_virtual_network.wls_vcn.cidr_block
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }

  ingress_security_rules {
    description = ""
    protocol    = "6"
    source      = oci_core_virtual_network.wls_vcn.cidr_block
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    tcp_options {
      max = "22"
      min = "22"
    }
  }
}