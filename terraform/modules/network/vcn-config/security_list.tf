# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.


resource "oci_core_security_list" "wls_security_list" {
  #Required
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "${var.resource_name_prefix}-${var.wls_security_list_name}"

  // allow outbound tcp traffic on all ports
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  // allow inbound ssh traffic
  ingress_security_rules {
    protocol  = 6 // tcp
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 22
      max = 22
    }
  }

  // allow public internet access to WLS admin console ssl port
  dynamic "ingress_security_rules" {
    iterator = cidr_iterator
    for_each = local.wls_admin_port_source_cidrs

    content {
      protocol  = "6" // tcp
      source    = cidr_iterator.value
      stateless = false

      tcp_options {
        min = var.wls_extern_ssl_admin_port
        max = var.wls_extern_ssl_admin_port
      }
    }
  }
  defined_tags  = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

resource "oci_core_security_list" "wls_internal_security_list" {
  #Required
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "${var.resource_name_prefix}-internal-security-list"

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  // allow access to all ports to all VMs on the specified subnet CIDR
  ingress_security_rules {
    protocol = "6"
    // tcp
    source    = var.wls_subnet_cidr
    stateless = false
  }
  defined_tags  = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

resource "oci_core_security_list" "wls_ms_security_list" {
  #Required
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "${var.resource_name_prefix}-wls-ms-security-list"

  // allow public internet access to managed server secure content port
  dynamic "ingress_security_rules" {
    # stateful ingress for OKE access to worker nodes on port 22 from the 6 source CIDR blocks: rules 5-11
    iterator = cidr_iterator
    for_each = var.wls_ms_source_cidrs

    content {
      protocol  = "6" // tcp
      source    = cidr_iterator.value
      stateless = false

      tcp_options {
        # SSL offloading happens at LB level. LB should be able to reach on MS HTTP port.
        min = var.load_balancer_min_value
        max = var.load_balancer_max_value
      }
    }
  }

  // allow public internet access to managed server content port
  dynamic "ingress_security_rules" {
    # stateful ingress for OKE access to worker nodes on port 22 from the 6 source CIDR blocks: rules 5-11
    iterator = cidr_iterator
    for_each = var.wls_ms_source_cidrs

    content {
      protocol  = "6" // tcp
      source    = cidr_iterator.value
      stateless = false

      tcp_options {
        min = var.wls_ms_content_port
        max = var.wls_ms_content_port
      }
    }
  }

  defined_tags  = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

resource "oci_core_security_list" "lb_security_list" {
  count = var.create_lb_sec_list ? 1 : 0

  #Required
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "${var.resource_name_prefix}-lb-security-list"

  // allow outbound tcp traffic on all ports
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "6" //tcp
  }

  // allow public internet access to http port
  ingress_security_rules {
    protocol  = "6" // tcp
    source    = var.lb_destination_cidr
    stateless = false

    tcp_options {
      min = local.port_for_ingress_lb_security_list
      max = local.port_for_ingress_lb_security_list
    }
  }

  defined_tags  = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

/*
* Create security rules for WLS private subnet
* Usage: Weblogic subnet
*
* Creates following secrules:
*   egress:
*     destination 0.0.0.0/0, protocol all
*   ingress:
*     Source <bastion_subnet_cidr>, protocol TCP, Destination Port: ALL
*/
resource "oci_core_security_list" "wls_bastion_security_list" {
  count          = var.existing_bastion_instance_id == "" && var.is_bastion_instance_required ? 1 : 0
  compartment_id = var.compartment_id
  display_name   = "${var.resource_name_prefix}-wls-bastion-security-list"
  vcn_id         = var.vcn_id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "all"
    source   = var.bastion_subnet_cidr
  }

  defined_tags  = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

/*
* Create security rules for WLS private subnet with existing bastion private ip
*/
resource "oci_core_security_list" "wls_existing_bastion_security_list" {
  count          = var.existing_bastion_instance_id != "" && var.is_bastion_instance_required ? 1 : 0
  compartment_id = var.compartment_id
  display_name   = "${var.resource_name_prefix}-wls-bastion-security-list"
  vcn_id         = var.vcn_id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "all"
    source   = format("%s/32", data.oci_core_instance.existing_bastion_instance[count.index].private_ip)
  }

  defined_tags  = var.tags.defined_tags
  freeform_tags = var.tags.freeform_tags
  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

# FSS security list
resource "oci_core_security_list" "fss_security_list" {
  count = var.add_fss && var.existing_mt_subnet_id == "" ? 1 : 0

  compartment_id = var.compartment_id
  display_name   = "${var.resource_name_prefix}-fss-seclist"
  vcn_id         = var.vcn_id

  egress_security_rules {
    destination = var.vcn_cidr
    protocol    = "6" // tcp
    stateless   = false
    tcp_options {
      source_port_range {
        max = 2050
        min = 2048
      }
    }
  }

  egress_security_rules {
    protocol    = "6" // tcp
    destination = var.vcn_cidr
    stateless   = false
    tcp_options {
      source_port_range {
        max = 111
        min = 111
      }
    }
  }

  egress_security_rules {
    protocol    = "17" // udp
    destination = var.vcn_cidr
    stateless   = false
    udp_options {
      source_port_range {
        max = 111
        min = 111
      }
    }
  }


  ingress_security_rules {
    protocol  = "6" // tcp
    source    = var.vcn_cidr
    stateless = false
    tcp_options {
      min = 2048
      max = 2050
    }
  }

  ingress_security_rules {
    protocol  = "6" // tcp
    source    = var.vcn_cidr
    stateless = false
    tcp_options {
      min = 111
      max = 111
    }
  }

  ingress_security_rules {
    protocol  = "17" // udp
    source    = var.vcn_cidr
    stateless = false
    udp_options {
      min = 2048
      max = 2048
    }
  }

  ingress_security_rules {
    protocol  = "17" // udp
    source    = var.vcn_cidr
    stateless = false
    udp_options {
      min = 111
      max = 111
    }
  }
}
