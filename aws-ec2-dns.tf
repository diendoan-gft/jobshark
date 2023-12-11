module "public_hosted_zone" {
  source      = "brunordias/route53-zone/aws"
  version     = "~> 1.0.0"
  domain      = var.route53_domain
  description = "Web app domain"
  tags        = var.tags
}

module "private_hosted_zone" {
  source      = "brunordias/route53-zone/aws"
  version     = "~> 1.0.0"
  domain      = var.route53_domain
  description = "Web app domain"
  private_zone = {
    vpc_id     = module.vpc.vpc_id
    vpc_region = var.region
  }
  tags = var.tags
}

# resource "aws_route53_record" "web_dns_record" {
#   zone_id = module.public_hosted_zone.zone_id
#   name    = var.route53_domain
#   type    = "CNAME"
#   ttl     = "300"
#   records = [] //[for value in values(module.alb.dns_name) : value]
# }
