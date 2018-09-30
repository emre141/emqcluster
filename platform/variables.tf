variable "environment" {}
variable "vpcid" {}
variable "aws_region" {}
variable "module_path" {}
variable "cert_external_name" {}
variable "cert_internal_name" {}
variable "isExternal" {}
variable "siemens_sgs-http-https" {
  type = "list"
}
variable "elb-external-extra-security-ws" {}
variable "elb-internal-security-group" {}
variable "ext_zone_id" {}
variable "int_zone_id" {}
variable "dnsname" {}
variable "emqansiblebucket" {}
variable "emqtt_cookies" {}
variable "emq_admin_password" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "emqtt_password" {}
variable "aws_ami_id" {}
variable "ssh_key_name" {}
variable "security_groups" {}
variable "emqtt_node_count" {}
variable "instance_type" {}
variable "subnetlistpublic" {
  type = "list"
}
variable "subnetlistprivate" {
  type = "list"
}