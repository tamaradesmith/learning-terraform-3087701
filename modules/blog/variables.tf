variable "instance_type" {
  description = "Type of EC2 instance to provision"
  default     = "t3.nano"
}

variable "ami_filter" {
  description = "Name filter and owner for AMI"

  type = object({
    name  = string
    owner = string
  })

  default = {
    name  = "bitnami-tomcat-*-x86_64-hvm-ebs-nami"
    owner = "979382823631" # Bitnami
  }
}

data "aws_vpc" "default" {
  default = true
}


variable enviroment {
  description = 'Development Environment'

  type = object({
    name            = string
    newtwork_prefix = string
  })

  default = {
    name            = "dev"
    newtwork_prefix = "10.0"
  }
}

variable 'asg_min_size' {
  description = "Minimun number of instances in the ASG"
  default     = 1
}

variable 'asg_max_size' {
  description = "Maxnimun number of instances in the ASG"
  default     = 2
}
