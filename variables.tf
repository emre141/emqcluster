#variable "vpc_id" {}
variable "aws_region" {}
variable "ssh_key_name" {}
variable "aws_ami_id" {}
variable "environment" {}
variable "emqansiblebucket" {}
variable "dnsname" {}
variable "MDSP_Area" {}
variable "MDSP_Environment" {}
variable "MDSP_Region_Datacenter" {}
variable "MDSP_Platform_Services" {}
variable "MDSP_Team" {}
variable "isDev" {}
variable "elb_security_group_cidr" {
  default = "0.0.0.0/0"
}
variable "isExternal" {
  default = 0
}
/*

variable "subnet_ids" {
  description = "Subnets for RabbitMQ nodes"
  type = "list"
}
*/
variable "asg_capacity" {
  default = 1
}

variable "ssh_security_group_ids" {
  description = "Security groups which should have SSH access to nodes."
  type = "list"
}
variable "elb_security_group_ids" {
  description = "Security groups which should have access to ELB (amqp + http ports)."
  type = "list"
}
variable "emq_admin_password" {}
variable "emqtt_password" {}
variable "instance_type" {}

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "cert_external_name" {}
variable "cert_internal_name" {}

variable "emqtt_cookies" {}
variable "emqtt_node_count" {}
variable "ref_arch_bucket" {
  description = "The bucket name of reference architecture, it starts with 'tf-state-xxxx'"
}
variable "ref_arch_path" {
  description = "The tfstate file where it is stored in reference architecture bucket"
}
