ref_arch_bucket = "<state_bucket>"
ref_arch_path = "<path-to-state>/terraform.state"

ssh_key_name = "rabbitmqtt"
instance_type = "t2.medium"
aws_region =  "eu-central-1"


ssh_security_group_ids  = []
elb_security_group_ids = []

cert_internal_name = "<internal issued certificate>"
cert_external_name = "<external issued certificate>"


emqtt_node_count = 3
aws_ami_id = "ami-7c4f7097" ## Latest Amazon Linux 2 AMI
environment = "dev-team7"
dnsname= "<any_dns_record_for_hostname>"
isExternal =1
emqansiblebucket = "<bucket_keept_ansible_role>"



