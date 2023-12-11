module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name   = "${var.env}-${var.owner}-alb-sg"
  vpc_id = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP access to ALB"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS access to ALB"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "web_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name   = "${var.env}-${var.owner}-web-sg"
  vpc_id = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      description              = "EC2 access from ALB"
      source_security_group_id = module.alb_sg.security_group_id
    },
    {
      from_port                = 443
      to_port                  = 443
      protocol                 = "tcp"
      description              = "EC2 access from ALB"
      source_security_group_id = module.alb_sg.security_group_id
    }
  ]
  egress_rules = ["all-all"]
  tags         = var.tags
}

module "rds_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = "${var.env}-${var.owner}-database-sg"
  description = "Complete PostgreSQL security group"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      description              = "PostgreSQL access from EC2"
      source_security_group_id = module.web_sg.security_group_id
    }
  ]
  egress_rules = ["all-all"]
  tags         = var.tags
}

