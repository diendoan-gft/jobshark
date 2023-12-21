# resource "random_password" "password" {
#   length           = 16
#   special          = true
#   override_special = "_%@"
# }

resource "aws_security_group" "public_ip_list" {
  name        = "${var.env}-${var.short_region}-public-sg"
  description = "Allow Postgress Access to Replica"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Postgres from Team member Home IP"
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}


module "db" {
  source     = "terraform-aws-modules/rds/aws"
  version    = "5.9.0"
  identifier = "${var.env}-${var.owner}-db"

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine               = "postgres"
  engine_version       = "14.4"
  family               = "postgres14" # DB parameter group
  major_engine_version = "14"         # DB option group
  instance_class       = var.db_instance

  allocated_storage      = 20
  max_allocated_storage  = 100
  create_random_password = false

  db_name  = aws_ssm_parameter.rds["/database/postgres/master/dbname"].value
  username = aws_ssm_parameter.rds["/database/postgres/master/username"].value
  password = aws_ssm_parameter.rds["/database/postgres/master/password"].value
  port     = var.db_port
  publicly_accessible = true
  multi_az = var.env != "prod" ? false : false
  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = module.vpc.private_subnets
  vpc_security_group_ids = [module.rds_sg.security_group_id, aws_security_group.public_ip_list.id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  create_cloudwatch_log_group     = true

  backup_retention_period = 1
  skip_final_snapshot     = true
  deletion_protection     = false
  storage_encrypted       = false

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_interval                   = 60
  monitoring_role_name                  = "${var.env}-${var.owner}-db-monitoring"
  monitoring_role_description           = "Description for monitoring role"

  tags       = var.tags
  depends_on = [module.vpc]
}
