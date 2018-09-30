data "aws_iam_policy_document" "policy_doc" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "template_file" "cloud-init" {
  template = "${file("${path.module}/cloud-init.yaml")}"

  vars {
    sync_node_count = 3
    region            = "${var.aws_region}"
    secret_cookie     = "${var.emqtt_cookies}"
    admin_password    = "${var.emq_admin_password}"
    emqtt_password    = "${var.emqtt_password}"
    message_timeout   = "${3 * 24 * 60 * 60 * 1000}"  # 3 days
    asgname           =  "${format("%s", "emq-${var.environment}")}"
    aws_access_key    = "${var.aws_access_key}"
    aws_secret_key    = "${var.aws_secret_key}"
    bucket_name       = "${var.emqansiblebucket}"
  }
}

resource "aws_iam_role" "role" {
  name               = "emq-${var.environment}"
  assume_role_policy = "${data.aws_iam_policy_document.policy_doc.json}"
}

resource "aws_iam_role_policy" "policy" {
  name   = "emq-${var.environment}"
  role   = "${aws_iam_role.role.id}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:*",
                "ec2:*",
                "s3:*",
                "cloudwatch:*",
                "ssm:*",
                "logs:*",
                "sns:*"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_instance_profile" "profile" {
  name = "emq-${var.environment}"
  role = "${aws_iam_role.role.name}"
}


resource "aws_launch_configuration" "emqtt" {
  name_prefix          =  "emq-${var.environment}"
  image_id             =  "${var.aws_ami_id}"
  instance_type        =  "${var.instance_type}"
  key_name             =  "${var.ssh_key_name}"
  security_groups      =  ["${var.security_groups}"]
  iam_instance_profile =  "${aws_iam_instance_profile.profile.id}"
  user_data            =  "${data.template_file.cloud-init.rendered}"

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_autoscaling_group" "emqtt" {
  name                      = "emq-${var.environment}"
  max_size                  = "${var.emqtt_node_count}"
  min_size                  = "${var.emqtt_node_count}"
  desired_capacity          = "${var.emqtt_node_count}"
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.emqtt.name}"
  load_balancers            = ["${var.isExternal == 1 ? aws_elb.elb-external.name : aws_elb.elb-internal.name}"]
  vpc_zone_identifier       = ["${var.subnetlistprivate}"]
  depends_on                = ["aws_launch_configuration.emqtt"]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key = "Name"
    value = "emq-${var.environment}"
    propagate_at_launch = true
  }
}