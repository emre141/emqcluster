resource "aws_security_group" "alb-external-extra-security-groups" {
  name        = "${var.environment}-ALB-extra-sg"
  description = "Allows port 443 for alb"
  vpc_id      = "${var.vpcid}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [
    "<any_required_cidr_block>"
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name                      = "${var.environment}-extra_sgs_for_external_alb"
  }
}


resource "aws_security_group" "alb-internal-security-group" {
  name        = "${var.environment}-internal-alb-sg"
  description = "Allows ports for internal alb"
  vpc_id      = "${var.vpcid}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [
      "<any_required_cidr_block>"
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name                      = "${var.environment}-internal-alb-sg"
  }
}