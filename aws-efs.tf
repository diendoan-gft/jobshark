# module "efs" {
#   source  = "cloudposse/efs/aws"
#   version = "0.35.0"

#   namespace                  = "eg"
#   for_each                   = toset(["${var.env}-${var.short_region}-${var.owner}-efs"])
#   name                       = each.key
#   region                     = var.region
#   vpc_id                     = module.vpc.vpc_id
#   subnets                    = module.vpc.public_subnets
#   stage                      = var.env
#   allowed_security_group_ids = module.web_sg.security_group_id
#   tags                       = var.tags
# }

module "efs" {
  source  = "terraform-aws-modules/efs/aws"
  version = "1.3.1"

  for_each = toset(["${var.env}-${var.short_region}-${var.owner}-efs"])
  name     = each.key
  lifecycle_policy = {
    transition_to_ia = "AFTER_30_DAYS"
  }

  # Backup policy
  enable_backup_policy = true
  tags                 = var.tags

}
