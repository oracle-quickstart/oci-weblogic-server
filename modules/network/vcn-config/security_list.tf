/*
 * Copyright (c) 2019, 2021, Oracle and/or its affiliates. All rights reserved.
 */

/*
* Creates a new security lists for the specified VCN.
* Also see: https://www.terraform.io/docs/providers/oci/r/core_security_list.html
*/

locals {
  port_for_ingress_lb_security_list = 443
  lb_destination_cidr               = var.is_lb_private ? var.bastion_subnet_cidr : "0.0.0.0/0"

  #if LB is requested and regional or single ad region, source: single lb subnet cidr
  #if LB is requested and non regional,  source: primary and secondary lb subnet cidrs
  #if no lb open it to anywhere,  source:"0.0.0.0/0"
  wls_ms_source_cidrs         = var.add_load_balancer ? ((var.use_regional_subnets || var.is_single_ad_region) ? [var.lb_subnet_1_cidr] : [var.lb_subnet_1_cidr, var.lb_subnet_2_cidr]) : ["0.0.0.0/0"]
  wls_admin_port_source_cidrs = var.wls_expose_admin_port ? [var.wls_admin_port_source_cidr] : []
}

/*
* Create security rules for WLS ssh and admin ports
* Usage: Weblogic subnet or bastion subnet
*
* Creates following secrules:
* egress:
*   destination 0.0.0.0/0, protocol all
* ingress:
*   Source 0.0.0.0/0, protocol TCP, Destination Port: 22 <ssh port>
*   Source 0.0.0.0/0, protocol TCP, Destination Port: <wls_ssl_admin_port>
*   Source <WLS Subnet CIDR>, protocol TCP, Destination Port: ALL
*/
resource "oci_core_security_list" "wls-security-list" {
  count = var.use_existing_subnets ? 0 : 1

  #Required
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "${var.service_name_prefix}-${var.wls_security_list_name}"

  // allow outbound tcp traffic on all ports
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  // allow inbound ssh traffic
  ingress_security_rules {
    protocol  = "6" // tcp
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
        min = var.wls_ssl_admin_port
        max = var.wls_ssl_admin_port
      }
    }
  }
  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags
}

/*
* Create security rules for WLS VM-VM access
* Usage: Weblogic subnet
*
* Creates following secrules:
* egress:
*   destination 0.0.0.0/0, protocol all
* ingress:
*   Source <wls_subnet_cidr>, protocol TCP, Destination Port: ALL
*/
resource "oci_core_security_list" "wls-internal-security-list" {
  count = var.use_existing_subnets ? 0 : 1

  #Required
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "${var.service_name_prefix}-internal-security-list"

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
  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags
}

/*
* Create security rules for WLS Managed servers, if LB is not requested
* Usage: Weblogic subnet or bastion subnet
*
* Creates following secrules:
*   ingress:
*     Source 0.0.0.0/0, protocol TCP, Destination Port: <wls_ms_ssl_port>
*     Source 0.0.0.0/0, protocol TCP, Destination Port: <wls_ms_port>
*/
resource "oci_core_security_list" "wls-ms-security-list" {
  count = var.use_existing_subnets ? 0 : 1

  #Required
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "${var.service_name_prefix}-wls-ms-security-list"

  // allow public internet access to managed server secure content port
  dynamic "ingress_security_rules" {
    # stateful ingress for OKE access to worker nodes on port 22 from the 6 source CIDR blocks: rules 5-11
    iterator = cidr_iterator
    for_each = local.wls_ms_source_cidrs

    content {
      protocol  = "6" // tcp
      source    = cidr_iterator.value
      stateless = false

      tcp_options {
        # SSL offloading happens at LB level. LB should be able to reach on MS HTTP port.
        min = var.add_load_balancer ? var.wls_ms_port : var.wls_ms_ssl_port
        max = var.add_load_balancer ? var.wls_ms_port : var.wls_ms_ssl_port
      }
    }
  }

  // allow public internet access to managed server content port
  dynamic "ingress_security_rules" {
    # stateful ingress for OKE access to worker nodes on port 22 from the 6 source CIDR blocks: rules 5-11
    iterator = cidr_iterator
    for_each = local.wls_ms_source_cidrs

    content {
      protocol  = "6" // tcp
      source    = cidr_iterator.value
      stateless = false

      tcp_options {
        min = var.is_idcs_selected ? var.idcs_cloudgate_port : var.wls_ms_ssl_port
        max = var.is_idcs_selected ? var.idcs_cloudgate_port : var.wls_ms_ssl_port
      }
    }
  }

  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags
}




/*
* Create security rules for LB
* Usage: Weblogic subnet or bastion subnet
*
* Creates following secrules:
*   egress:
*     destination 0.0.0.0/0, protocol all
*   ingress:
*     Source 0.0.0.0/0, protocol TCP, Destination Port: 80 or 443
*/
resource "oci_core_security_list" "lb-security-list" {
  count = (var.add_load_balancer && var.use_existing_subnets == false) ? 1 : 0

  #Required
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "${var.service_name_prefix}-lb-security-list"

  // allow outbound tcp traffic on all ports
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "6" //tcp
  }

  // allow public internet access to http port
  ingress_security_rules {
    protocol  = "6" // tcp
    source    = local.lb_destination_cidr
    stateless = false

    tcp_options {
      min = local.port_for_ingress_lb_security_list
      max = local.port_for_ingress_lb_security_list
    }
  }

  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags
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
resource "oci_core_security_list" "wls-bastion-security-list" {
  count          = ! var.assign_backend_public_ip && ! var.use_existing_subnets && var.existing_bastion_instance_id == "" && var.is_bastion_instance_required ? 1 : 0
  compartment_id = var.compartment_id
  display_name   = "${var.service_name_prefix}-wls-bastion-security-list"
  vcn_id         = var.vcn_id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "all"
    source   = var.bastion_subnet_cidr
  }

  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags

}

/*
* Create security rules for WLS private subnet with existing bastion private ip
*/
resource "oci_core_security_list" "wls-existing-bastion-security-list" {
  count          = ! var.assign_backend_public_ip && ! var.use_existing_subnets && var.existing_bastion_instance_id != "" && var.is_bastion_instance_required ? 1 : 0
  compartment_id = var.compartment_id
  display_name   = "${var.service_name_prefix}-wls-bastion-security-list"
  vcn_id         = var.vcn_id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "all"
    source   = format("%s/32", data.oci_core_instance.existing_bastion_instance[count.index].private_ip)
  }

  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags

}

# FSS security list
resource "oci_core_security_list" "fss-security-list" {
  count = var.add_fss && var.existing_mt_subnet_id == "" ? 1 : 0

  compartment_id = var.compartment_id
  display_name   = "${var.service_name_prefix}-fss-seclist"
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
