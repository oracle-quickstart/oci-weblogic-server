# Copyright (c) 2023, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "tls_private_key" "ss_private_key" {
  count     = local.use_https_listener_count
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "tls_self_signed_cert" "demo_cert" {
  count           = local.use_https_listener_count
  private_key_pem = tls_private_key.ss_private_key[count.index].private_key_pem

  subject {
    common_name         = format("%s", var.resource_name_prefix)
    organization        = "Demo"
    organizational_unit = "FOR TESTING ONLY"
  }

  #1 year validity
  validity_period_hours = 24 * 365

  allowed_uses = [
    "digital_signature",
    "cert_signing",
    "crl_signing",
  ]
}


resource "oci_load_balancer_certificate" "demo_certificate" {
  count = local.use_https_listener_count
  #Required
  certificate_name = "${var.resource_name_prefix}_${var.lb_certificate_name}"
  load_balancer_id = var.load_balancer_id

  #Optional
  public_certificate = tls_self_signed_cert.demo_cert[count.index].cert_pem
  private_key        = tls_private_key.ss_private_key[count.index].private_key_pem

  lifecycle {
    create_before_destroy = true
  }
}