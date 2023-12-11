# module "ec2_instance" {
#   source  = "terraform-aws-modules/ec2-instance/aws"
#   version = "5.5.0"
#   name    = "${var.env}-${var.short_region}-ec2-jobshark"

#   instance_type          = var.ec2_instance
#   key_name               = "ec2-keypair-jobshark"
#   monitoring             = true
#   vpc_security_group_ids = module.web_sg.security_group_id
#   subnet_id              = module.vpc.private_subnets[0]

#   tags = var.tags
# }
