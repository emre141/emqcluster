output "aws_ami_id_from_filter" {
  value = "${data.aws_ami.ami.image_id}"
}