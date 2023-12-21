
# Create EBS Vol for Data
data "aws_availability_zones" "available" {}

locals {
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
}

resource "aws_ebs_volume" "this" {
  availability_zone = element(local.azs, 0)
  size              = 150
  tags = var.tags
}
resource "aws_volume_attachment" "this" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.this.id
  instance_id = module.ec2_instance.id
}

# EC2
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "4.2.1"
  name    = "${var.env}-${var.short_region}-ec2-jobshark"

  instance_type          = var.ec2_instance
  ami                    = var.ec2_ami         
  key_name               = "ubuntu-keypair"
  availability_zone      = element(local.azs, 0)
  monitoring             = true
  vpc_security_group_ids = [module.web_sg.security_group_id]
  subnet_id              = element(module.vpc.public_subnets, 0)
  associate_public_ip_address = true
  user_data              = filebase64("${path.module}/script/script.sh")
  iam_instance_profile   = aws_iam_instance_profile.ec2_ssm_iam_profile.name
  enable_volume_tags = true
  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
    #   throughput  = 200
      volume_size = 50
    },
  ]
  tags = var.tags
}
