resource "random_string" "random" {
  length  = 3
  special = false
}

resource "aws_iam_service_linked_role" "autoscaling" {
  aws_service_name = "autoscaling.amazonaws.com"
  description      = "A service linked role for autoscaling"
  custom_suffix    = "${var.env}-${var.owner}-asg-${random_string.random.result}"

  # Sometimes good sleep is required to have some IAM resources created before they can be used
  provisioner "local-exec" {
    command = "sleep 10"
  }
}

locals {
  user_data = base64encode(templatefile("${path.module}/script/script.sh", {
    efs_id = module.efs["${var.env}-${var.short_region}-${var.owner}-efs"].id
  }))
  depends_on = [module.efs]
}

resource "aws_launch_template" "web" {
  name_prefix            = "web-"
  image_id               = var.ec2_ami
  instance_type          = var.ec2_instance
  # vpc_security_group_ids = [module.web_sg.security_group_id]

  update_default_version = true
  ebs_optimized          = false
  user_data              = filebase64("${path.module}/script/script.sh")
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_ssm_iam_profile.name
  }
  metadata_options {
    http_tokens = "required"
  }
  block_device_mappings {
    device_name = "/dev/sdb"
    ebs {
      volume_size = 150
    }
  }
  lifecycle {
    create_before_destroy = true
  }
  network_interfaces {
    security_groups             = [module.web_sg.security_group_id]
    associate_public_ip_address = false
    device_index                = 0
  }
  tags = var.tags
}

module "ec2_asg" {
  source                    = "terraform-aws-modules/autoscaling/aws"
  version                   = "6.5.1"
  name                      = "${var.env}-${var.short_region}-${var.owner}-asg"
  vpc_zone_identifier       = module.vpc.public_subnets
  health_check_type         = "ELB"
  health_check_grace_period = 600
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  wait_for_capacity_timeout = 0
  default_cooldown          = 600
  target_group_arns         = module.alb.target_group_arns
  create_launch_template    = false
  security_groups    = [module.web_sg.security_group_id]
  # Launch template  
  launch_template             = aws_launch_template.web.name
  launch_template_description = "Jobshark autoscaling template"
  update_default_version      = true
  image_id                    = var.ec2_ami
  instance_type               = var.ec2_instance
  enabled_metrics             = ["GroupPendingInstances", "GroupPendingCapacity", "GroupMaxSize", "GroupInServiceInstances", "GroupDesiredCapacity", "GroupTotalInstances", "GroupTerminatingInstances", "GroupTotalCapacity", "GroupStandbyCapacity", "GroupInServiceCapacity", "GroupInServiceCapacity", "GroupStandbyInstances", "GroupMinSize"]

  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      min_healthy_percentage = 50
      instance_warmup        = 300
      checkpoint_delay       = 300
      checkpoint_percentages = [30, 50, 75]
    }
  }
  mixed_instances_policy = {
    instances_distribution = {
      # spot_max_price                           = "0.07"
      spot_instance_pools                      = 3
      spot_allocation_strategy                 = "capacity-optimized"
      on_demand_percentage_above_base_capacity = 50
      on_demand_base_capacity                  = 1
      on_demand_allocation_strategy            = "prioritized"
    }
  }
  tags = var.tags
}
