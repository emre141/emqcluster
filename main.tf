provider "aws" {
  region     = "${var.aws_region}"
}

provider "archive" {
  version = "~> 1.0"
}

terraform {
  backend "s3" {}
}

resource "null_resource" "set_path" {
  triggers = {
    path_module = "${path.module}"
  }
}

module "emqcluster" {
  source = "platform"
  environment =                         "${var.environment}"
  siemens_sgs_ref_arc  =                "${data.terraform_remote_state.reference_arch.siemens-securitygroups-https}"
  vpcid =                               "${data.terraform_remote_state.reference_arch.vpc_id}"
  module_path  =                        "${null_resource.set_path.triggers.path_module}"
  subnetlistpublic       =              ["${data.terraform_remote_state.reference_arch.public-subnets}"]
  subnetlistprivate      =              ["${data.terraform_remote_state.reference_arch.priv-subnets}"]
  cert_external_name =                  "${var.cert_external_name}"
  cert_internal_name =                  "${var.cert_internal_name}"
  aws_region =                          "${var.aws_region}"
  isExternal =                          "${var.isExternal}"
  security_groups                       ="${aws_security_group.emqtt_nodes.id}"
  siemens_sgs-http-https =               ["${data.terraform_remote_state.reference_arch.siemens-securitygroups-http-https}"]
  elb-external-extra-security-ws=       "${aws_security_group.elb-external-extra-security-ws.id}"
  elb-internal-security-group =          "${aws_security_group.elb-internal-security-group.id}"
  ext_zone_id =                          "${data.terraform_remote_state.reference_arch.ext_zone_id}"
  int_zone_id =                          "${data.terraform_remote_state.reference_arch.int_zone_id}"
  dnsname=                               "${var.dnsname}"
  emqansiblebucket=                      "${var.emqansiblebucket}"
  emqtt_cookies                          = "${var.emqtt_cookies}"
  emq_admin_password                     = "${var.emq_admin_password}"
  emqtt_password                         = "${var.emqtt_password}"
  aws_access_key                         = "${var.aws_secret_key}"
  aws_secret_key                         = "${var.aws_secret_key}"
  aws_ami_id                             = "${var.aws_ami_id}"
  instance_type                          = "${var.instance_type}"
  ssh_key_name                           = "${var.ssh_key_name}"
  emqtt_node_count                       = "${var.emqtt_node_count}"
}

data "terraform_remote_state" "reference_arch" {
  backend = "s3"

  config {
    bucket = "${var.ref_arch_bucket}"
    key    = "${var.ref_arch_path}"
    region = "${var.aws_region}"
  }
}

data "aws_ami" "ami" {
  most_recent = true


  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }


  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}



