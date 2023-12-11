resource "random_password" "postgres_password" {
  length           = 19
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

locals {
  ssm_db_group = {
    "/database/postgres/master/username" = var.db_username
    "/database/postgres/master/password" = random_password.postgres_password.result
    "/database/postgres/master/dbname"   = var.db_name
  }
}

resource "aws_ssm_parameter" "rds" {
  description = "The parameter description"
  type        = "SecureString"
  overwrite   = true
  for_each    = local.ssm_db_group
  name        = each.key
  value       = each.value
  tags        = var.tags
}
