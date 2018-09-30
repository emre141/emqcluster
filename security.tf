resource "aws_security_group" "elb-external-extra-security-ws" {
  name        = "emqtt-siemens-sg1-mqtt-and-ws-${var.environment}"
  description = "Allows port mqtt for lb"
  vpc_id      = "${data.terraform_remote_state.reference_arch.vpc_id}"

  ingress {
    from_port   = 8083
    to_port     = 8083
    protocol    = "tcp"
    cidr_blocks = [
      "<required_cidr_block>"
    ]
  }

  ingress {
    from_port   = 1883
    to_port     = 1883
    protocol    = "tcp"
    cidr_blocks = [
      "<required_cidr_block>"
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "emqtt-siemens-sg1-ws"

  }
}


resource "aws_security_group" "emqtt_nodes" {
  name        = "emq-nodes-${var.environment}"
  vpc_id      = "${data.terraform_remote_state.reference_arch.vpc_id}"
  description = "Security Group for the EMQ  nodes"

  ingress {
    protocol  = -1
    from_port = 0
    to_port   = 0
    self      = true
  }

  ingress {
    protocol        = "tcp"
    from_port       = 0
    to_port         = 65535
    cidr_blocks = ["${var.elb_security_group_cidr}"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags {
    Name = "EMQ nodes"
  }
}

resource "aws_security_group" "elb-internal-security-group" {
  name        = "emq-elb-${var.environment}-internal"
  description = "Security Group for the EMQ  ELB Internal"
  vpc_id      = "${data.terraform_remote_state.reference_arch.vpc_id}"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["${var.elb_security_group_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

