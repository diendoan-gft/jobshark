# Tag
tags = {
  "environment" = "prod"
  "created-by"  = "terraform"
  "owner"       = "comstream"
  "tag-version" = "1"
}

owner               = "comstream"
region              = "eu-north-1"
env                 = "prod"
team                = "comstream"
createdBy           = "terraform"
short_region        = "eun1"
availability_zones  = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
cidr_block          = "172.16.0.0/16"
public_subnets      = ["172.16.100.0/24", "172.16.101.0/24", "172.16.102.0/24"]
app_private_subnets = ["172.16.0.0/24", "172.16.1.0/24", "172.16.2.0/24"]
db_private_subnet   = ["172.16.200.0/24", "172.16.201.0/24"]

ec2_instance     = "t3.large"
ec2_ami          = "ami-0fe8bec493a81c7da"
min_size         = "1"
max_size         = "3"
desired_capacity = "1"
#DB
db_instance    = "db.t3.medium"
db_username    = "jobsharkadmin"
db_name        = "jobsharkdb"
db_port        = "5432"
