resource "aws_elb" "elb-external" {
  name = "emq-elb-${var.environment}-external"

  access_logs {
    bucket = "${aws_s3_bucket.external_elb_s3_bucket.bucket}"
    enabled = true
  }

  listener {
    instance_port      = 18083
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "${data.aws_acm_certificate.cert_external.arn}"
  }

  listener {
    instance_port      = 1883
    instance_protocol  = "tcp"
    lb_port            = 1883
    lb_protocol        = "tcp"
  }

  listener {
    instance_port = 8883
    instance_protocol = "SSL"
    lb_port = 8883
    lb_protocol = "SSL"
    ssl_certificate_id = "${data.aws_acm_certificate.cert_external.arn}"
  }

  listener {
    instance_port = 8084
    instance_protocol = "SSL"
    lb_port = 8084
    lb_protocol = "SSL"
    ssl_certificate_id = "${data.aws_acm_certificate.cert_external.arn}"
  }

  listener {
    instance_port      = 8083
    instance_protocol  = "tcp"
    lb_port            = 8083
    lb_protocol        = "tcp"
  }


  health_check {
    interval            = 30
    unhealthy_threshold = 10
    healthy_threshold   = 2
    timeout             = 3
    target              = "TCP:1883"
  }

  subnets               = ["${var.subnetlistpublic}"]
  idle_timeout          = 3600
  internal              = false
  security_groups       = ["${var.siemens_sgs-http-https}","${var.elb-external-extra-security-ws}"]

  tags {
    Name = "emqtt"
  }
}

resource "aws_elb" "elb-internal" {
  name                 = "emq-elb-${var.environment}-internal"

  access_logs {
    bucket = "${aws_s3_bucket.internal_elb_s3_bucket.bucket}"
    enabled = true

  }

  listener {
    instance_port      = 18083
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "${data.aws_acm_certificate.cert_external.arn}"
  }


  listener {
    instance_port      = 1883
    instance_protocol  = "tcp"
    lb_port            = 1883
    lb_protocol        = "tcp"
  }

  listener {
    instance_port      = 8083
    instance_protocol  = "tcp"
    lb_port            = 8083
    lb_protocol        = "tcp"
  }

  listener {
    instance_port = 8883
    instance_protocol = "SSL"
    lb_port = 8883
    lb_protocol = "SSL"
    ssl_certificate_id = "${data.aws_acm_certificate.cert_external.arn}"
  }

  listener {
    instance_port = 8084
    instance_protocol = "SSL"
    lb_port = 8084
    lb_protocol = "SSL"
    ssl_certificate_id = "${data.aws_acm_certificate.cert_external.arn}"
  }

  health_check {
    interval            = 30
    unhealthy_threshold = 10
    healthy_threshold   = 2
    timeout             = 3
    target              = "TCP:1883"
  }

  subnets               = ["${var.subnetlistprivate}"]
  idle_timeout          = 3600
  internal              = true
  security_groups       = ["${var.elb-internal-security-group}"]

  tags {
    Name = "emqtt"
  }
}

resource "aws_route53_record" "emq" {
  name = "${var.dnsname}"
  type = "A"
  zone_id = "${var.isExternal == 1 ? var.ext_zone_id : var.int_zone_id}"

  alias {
    evaluate_target_health = true
    name = "${var.isExternal == 1 ? aws_elb.elb-external.dns_name : aws_elb.elb-internal.dns_name}"
    zone_id = "${var.isExternal == 1 ? aws_elb.elb-external.zone_id : aws_elb.elb-internal.zone_id}"
  }
}

