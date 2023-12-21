variable "tags" {
  type        = map(string)
  description = "Map of predefined tags"
}

variable "app_private_subnets" {
  description = ""
}

variable "availability_zones" {
  description = ""
}

variable "cidr_block" {
  description = ""
}

variable "createdBy" {
  description = ""
}

variable "env" {
  description = ""
}

variable "owner" {
  description = ""
}

variable "public_subnets" {
  description = ""
}

variable "short_region" {
  description = ""
}

variable "region" {
  description = ""
}

variable "team" {
  description = ""
}

# EC2
variable "ec2_instance" {
  description = "DB instance type"
  default     = "t3.micro"
}

variable "ec2_ami" {
  description = "EC2 AMI"
  default     = "ami-0fe8bec493a81c7da"
}

variable "min_size" {
  description = "minimum size "
  default     = "1"
}

variable "max_size" {
  description = "maximum size"
  default     = "3"
}

variable "desired_capacity" {
  description = "descire size"
  default     = "1"
}

# RDS

#DB
variable "db_instance" {
  description = "DB instance type"
  default     = "db.t3.micro"
}

variable "db_username" {
  description = "DB Username"
  default     = ""
}

variable "db_name" {
  description = "DB Name"
  default     = ""
}

variable "db_port" {
  description = "DB Port"
  default     = "5432"
}

variable "db_private_subnet" {
}

# Route53
variable "route53_domain" {
  default = "example.com"
}
