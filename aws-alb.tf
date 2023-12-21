
module "alb" {
  source             = "terraform-aws-modules/alb/aws"
  version            = "~> 6.0"
  name               = "${var.env}-${var.short_region}-alb-jobshark"
  load_balancer_type = "application"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups    = [module.alb_sg.security_group_id]
  http_tcp_listeners = [
    {
      port               = 80,
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]
  # https_listeners = [
  #   {
  #     port               = 443
  #     protocol           = "HTTPS"
  #     certificate_arn    = "" //need to update
  #     target_group_index = 0
  #   }
  # ]
  target_groups = [
    {
      name_prefix      = "web",
      backend_protocol = "HTTP",
      backend_port     = 80
      target_type      = "instance"
      health_check = {
        enabled             = true
        interval            = 60
        path                = "/"
        port                = 80
        healthy_threshold   = 3
        unhealthy_threshold = 5
        timeout             = 15
        protocol            = "HTTP"
        matcher             = "200"
      }
    }
  ]

  tags = var.tags
}
