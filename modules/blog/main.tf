data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.ami_filter.name]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = [var.ami_filter.owner]
}

data "aws_vpc" "default" {
  default = true
}

module "blog_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.enviroment.name
  cidr = "${var.enviroment.newtwork_prefix}.0.0/16"

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  public_subnets  = ["${var.enviroment.newtwork_prefix}.101.0/24", "${var.enviroment.newtwork_prefix}.102.0/24", "${var.enviroment.newtwork_prefix}.103.0/24"]

  tags = {
    Terraform   = "true"
    Environment = var.enviroment.name
  }
}

module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "7.4.0"

  name     = "${var.enviroment.name}-blog"
  min_size = var.asg_min_size
  max-size = var.asg_max_size

  vpc_zone_identifier = module.blog_vpc.public_subnets
  target_group_arns   = module.blog_alb.target_group_arns
  security_groups     = [module.blog_sq.security_group_id]

  iamge_id      = data.aws_ami.app_ami.id
  instance_type = var.instance_type

}



#  not updated  for new module code this is not right
module "blog_alb" {
  source = "terraform-aws-modules/alb/aws"

  name     = "${var.enviroment.name}-blog_alb"

  vpc_id         = module.blog_vpc.vpc_id
  subnets        = module.blog_vpc.public_subnets
  security_groups = [module.blog_sg.security_group_id]

  # Security Group
  security_group_ingress_rules = module.blog_sg.security_group_id
  security_group_egress_rules  = module.blog_sg.security_group_id

  listeners = {
    ex-http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    ex-https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"

      forward = {
        target_group_key = "ex-instance"
      }
    }
  }

  target_groups = {
    ex-instance = {
      name_prefix      = "${var.enviroment.name}-"
      protocol         = "HTTP"
      port             = 80
      target_type      = "instance"
    }
  }

  tags = {
    Environment = var.enviroment.name
  }
}

module "blog_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"
  name    = "${var.enviroment.name}-blog"

  vpc_id  = module.blog_vpc.vpc_id
  
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}
