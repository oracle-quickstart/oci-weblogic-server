# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  /* count decides whether to provision load balancer */
  use_https_listener_count = !var.use_existing_lb ? 1 : 0
  health_check_url_path    = var.health_check_url
}

resource "oci_load_balancer_backend_set" "wls_lb_backendset" {
  # If using existing load balancer, use per-created backend set of existing lb
  count = var.use_existing_lb ? 0 : 1

  name             = var.lb_backendset_name
  load_balancer_id = var.load_balancer_id
  policy           = var.lb_policy

  health_checker {
    port                = var.lb_port
    protocol            = var.lb_protocol
    response_body_regex = ".*"
    url_path            = local.health_check_url_path
    return_code         = var.return_code
  }

  # Set the session persistence to lb-session-persistence with all default values.
  lb_cookie_session_persistence_configuration {}
}

resource "oci_load_balancer_listener" "wls_lb_listener_https" {
  count                    = local.use_https_listener_count
  load_balancer_id         = var.load_balancer_id
  name                     = "${var.resource_name_prefix}_https"
  default_backend_set_name = var.use_existing_lb ? var.lb_backendset_name : oci_load_balancer_backend_set.wls_lb_backendset[count.index].name
  port                     = var.lb_https_lstr_port
  protocol                 = var.lb_protocol
  rule_set_names           = [oci_load_balancer_rule_set.SSL_headers[count.index].name]

  connection_configuration {
    idle_timeout_in_seconds = "10"
  }
  ssl_configuration {
    #Required
    certificate_name        = oci_load_balancer_certificate.demo_certificate.certificate_name
    verify_peer_certificate = false
  }
}

resource "oci_load_balancer_backend" "wls_lb_backend" {
  count = var.use_existing_lb || (length(oci_load_balancer_backend_set.wls_lb_backendset) > 0) ? var.num_vm_instances : 0

  load_balancer_id = var.load_balancer_id
  backendset_name  = var.use_existing_lb ? var.lb_backendset_name : oci_load_balancer_backend_set.wls_lb_backendset[0].name
  ip_address       = var.instance_private_ips[count.index]
  port             = var.lb_port
  backup           = false
  drain            = false
  offline          = false
  weight           = var.policy_weight

  lifecycle {
    ignore_changes = [offline]
  }
}

resource "oci_load_balancer_rule_set" "SSL_headers" {
  count = local.use_https_listener_count

  load_balancer_id = var.load_balancer_id
  name             = "${var.resource_name_prefix}_SSLHeaders"
  items {
    action = "ADD_HTTP_REQUEST_HEADER"
    header = "WL-Proxy-SSL"
    value  = "true"
  }
  items {
    action = "ADD_HTTP_REQUEST_HEADER"
    header = "is_ssl"
    value  = "ssl"
  }
}

resource "oci_load_balancer_certificate" "demo_certificate" {

  #Required
  certificate_name = "${var.resource_name_prefix}_${var.lb_certificate_name}"
  load_balancer_id = var.load_balancer_id

  #Optional
  public_certificate = tls_self_signed_cert.demo_cert.cert_pem
  private_key        = tls_private_key.ss_private_key.private_key_pem

  lifecycle {
    create_before_destroy = true
  }
}
