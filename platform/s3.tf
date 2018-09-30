resource "null_resource" "set_path" {
  triggers = {
    path_module = "${path.module}"
  }
}


data "archive_file" "archive-ansible" {
  source_dir = "${path.module}/ansible/"
  output_path = "${format("%s%s","emq-${var.environment}",".zip")}"
  type = "zip"
}


resource "aws_s3_bucket_object" "ansibledirectory" {
  bucket = "${var.emqansiblebucket}"
  key =    "ansible"
  source = "${data.archive_file.archive-ansible.output_path}"
  etag = "${data.archive_file.archive-ansible.output_md5}"
}

data "aws_caller_identity" "current" {

}

data "template_file" "encrypted_bucket_policy_for_int_elb" {
  template = "${file((format("%s","${null_resource.set_path.triggers.path_module}/policy.json")))}"

  vars {
    bucket_name = "${var.environment}-${data.aws_caller_identity.current.account_id}-internal-elb-logs"
    account_id  = "${data.aws_caller_identity.current.account_id}"
  }
}

data "template_file" "encrypted_bucket_policy_for_ext_elb" {
  template = "${file((format("%s","${null_resource.set_path.triggers.path_module}/policy.json")))}"

  vars {
    bucket_name = "${var.environment}-${data.aws_caller_identity.current.account_id}-external-elb-logs"
    account_id  = "${data.aws_caller_identity.current.account_id}"
  }
}

resource "aws_s3_bucket" "external_elb_s3_bucket" {
  bucket = "${var.environment}-${data.aws_caller_identity.current.account_id}-external-elb-logs"
  acl    = "private"
  force_destroy = true

  versioning {

    enabled = "true"
  }

  lifecycle_rule {

    enabled = "true"

    transition {
      days = "5"
      storage_class = "GLACIER"
    }
  }

  policy = "${data.template_file.encrypted_bucket_policy_for_ext_elb.rendered}"
}

resource "aws_s3_bucket" "internal_elb_s3_bucket" {
  bucket = "${var.environment}-${data.aws_caller_identity.current.account_id}-internal-elb-logs"
  acl    = "private"
  force_destroy = true

  versioning {
    enabled = "true"
  }

  lifecycle_rule {

    enabled = "true"

    transition {
      days = "5"
      storage_class = "GLACIER"
    }
  }

  policy = "${data.template_file.encrypted_bucket_policy_for_int_elb.rendered}"
}


