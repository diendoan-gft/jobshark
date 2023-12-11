# Tag
tags = {
  "environment" = "dev"
  "created-by"  = "terraform"
  "owner"       = "devops"
  "tag-version" = "1"
}

owner               = "jobshark"
region              = "eu-north-1"
env                 = "dev"
team                = "devops"
createdBy           = "terraform"
short_region        = "eun1"
availability_zones  = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
cidr_block          = "172.16.0.0/16"
public_subnets      = ["172.16.100.0/24", "172.16.101.0/24", "172.16.102.0/24"]
app_private_subnets = ["172.16.0.0/24", "172.16.1.0/24", "172.16.2.0/24"]
db_private_subnet   = ["172.16.200.0/24", "172.16.201.0/24"]

ec2_instance     = "t3.micro"
ec2_ami          = "ami-0416c18e75bd69567"
min_size         = "1"
max_size         = "3"
desired_capacity = "1"
#DB
instance_class = "db.t3.micro"
db_username    = "jobsharkadmin"
db_name        = "jobsharkdb"
route53_domain = "jobshark.testxyz"
db_port        = "5432"
