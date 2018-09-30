variable "siemens_sgs_ref_arc" {
  type = "list"
}

#--- External ALB---#
resource "aws_alb" "service_alb_external" {
  name            = "${var.environment}-ALB"
  internal        = false
  security_groups = ["${var.siemens_sgs_ref_arc}","${aws_security_group.alb-external-extra-security-groups.id}"]

  access_logs {
    enabled = true
    bucket = "${aws_s3_bucket.external_elb_s3_bucket.bucket}"
  }

  subnets = ["${var.subnetlistpublic}"]

  tags {
    Name = "${var.environment}-alb"
  }
}

#--- Internal ALB---#
resource "aws_alb" "service_alb_internal" {
  name            = "${var.environment}-ALB-internal"
  internal        = true
  security_groups = ["${aws_security_group.alb-internal-security-group.id}"]
  subnets         = ["${var.subnetlistprivate}"]

  access_logs {
    enabled = true
    bucket = "${aws_s3_bucket.external_elb_s3_bucket.bucket}"
  }

  tags {
    Name        = "${var.environment}-alb-internal"
  }
}

#--- External TG for External ALB---#
resource "aws_alb_target_group" "service_alb_target_group" {
  name     = "${var.environment}-TG"
  port     = "443"
  protocol = "HTTPS"
  vpc_id   = "${var.vpcid}"

  tags {
    Name        = "${var.environment}-tg"
  }
}

#--- Internal TG for Internal ALB---#
resource "aws_alb_target_group" "service_alb_internal_target_group" {
  name     = "${var.environment}-internal-TG"
  port     = "443"
  protocol = "HTTPS"
  vpc_id   = "${var.vpcid}"

  tags {
    Name        = "${var.environment}-internal-tg"
  }
}

#--- External Listener for External ALB---#
resource "aws_alb_listener" "service_alb_listener" {
  load_balancer_arn = "${aws_alb.service_alb_external.arn}"
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn = "${data.aws_acm_certificate.cert_external.arn}"

  default_action  {
    target_group_arn = "${aws_alb_target_group.service_alb_target_group.arn}"
    type             = "forward"
  }
  ssl_policy         = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

#--- Internal Listener for Internal ALB---#
resource "aws_alb_listener" "service_alb_internal_listener" {
  load_balancer_arn = "${aws_alb.service_alb_internal.arn}"
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn = "${data.aws_acm_certificate.cert_internal.arn}"

  default_action  {
    target_group_arn  = "${aws_alb_target_group.service_alb_internal_target_group.arn}"
    type              = "forward"
  }
  ssl_policy         = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

#--- External https cert for External ALB---#
data "aws_acm_certificate" "cert_external" {
  domain   = "${var.cert_external_name}"
  statuses = ["ISSUED"]
}

#--- Internal https cert for Internal ALB---#
data "aws_acm_certificate" "cert_internal" {
  domain   = "${var.cert_internal_name}"
  statuses = ["ISSUED"]
}

