module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  version            = "5.2.0"
  name               = "${var.env}-${var.short_region}-vpc"
  cidr               = var.cidr_block
  azs                = var.availability_zones
  private_subnets    = var.app_private_subnets
  public_subnets     = var.public_subnets
  database_subnets   = var.db_private_subnet
  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = false
  tags               = var.tags
}
