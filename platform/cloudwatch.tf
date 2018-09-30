data "aws_iam_policy_document" "ssm_lifecycle_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}


data "template_file" "ssmpolicy" {
  template = "${file((format("%s","${null_resource.set_path.triggers.path_module}/runpolicy.json")))}"

  vars {
    account_id  = "${data.aws_caller_identity.current.account_id}"
    resourcetag = "emq-${var.environment}"
  }
}

resource "aws_iam_policy" "ssm-run-command" {
  name = "emq-${var.environment}-policy"
  policy = "${data.template_file.ssmpolicy.rendered}"
}


resource "aws_iam_role_policy_attachment" "ssm-run-command" {
  policy_arn = "${aws_iam_policy.ssm-run-command.arn}"
  role = "${aws_iam_role.emq_ssm_run.name}"
}

resource "aws_iam_role" "emq_ssm_run" {
  assume_role_policy = "${data.aws_iam_policy_document.ssm_lifecycle_trust.json}"
  name = "emq-ssm-${var.environment}"
}


resource "aws_cloudwatch_event_rule" "ansible" {
  name = "emq-${var.environment}-ansible"
  description = "Run Playbook When any Action on Autoscaling Group"
  is_enabled = false
  event_pattern = <<PATTERN
  {
    "source": [
      "aws.autoscaling"
    ],
    "detail-type": [
      "EC2 Instance Launch Successful",
      "EC2 Instance Terminate Successful",
      "EC2 Instance Launch Unsuccessful",
      "EC2 Instance Terminate Unsuccessful",
      "EC2 Instance-launch Lifecycle Action",
      "EC2 Instance-terminate Lifecycle Action"
    ],
    "detail": {
      "AutoScalingGroupName": [
        "emq-${var.environment}"
      ]
    }
  }

PATTERN
}

resource "aws_cloudwatch_event_target" "emqansibletarget" {
  arn = "arn:aws:ssm:${var.aws_region}::document/AWS-RunShellScript"
  target_id = "AutoScalingEvent"
  rule = "${aws_cloudwatch_event_rule.ansible.name}"
  input = "{\"commands\": [\"ansible-playbook /etc/ansible/roles/emqcluster/emqttcluster.yaml --connection=local --extra-vars='asgname=emq-${var.environment}'\"]}"
  role_arn = "${aws_iam_role.emq_ssm_run.arn}"

  run_command_targets {
    key = "tag:Name"
    values = ["emq-${var.environment}"]
  }
}




resource "aws_ssm_document" "runshellansible" {
  name          = "run_ansible_command"
  document_type = "Command"

  content = <<DOC
  {
    "schemaVersion": "1.2",
    "description": "Run Ansible Playbook",
    "parameters": {

    },
    "runtimeConfig": {
      "aws:runShellScript": {
        "properties": [
          {
            "id": "0.aws:runShellScript",
            "runCommand": [" ansible-playbook /etc/ansible/roles/emqcluster/emqttcluster.yaml --connection=local --extra-vars='asgname=emq-${var.environment}'"]
          }
        ]
      }
    }
  }
DOC
}
