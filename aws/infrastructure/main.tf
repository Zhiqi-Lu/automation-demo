terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "ap-northeast-1"
  profile = "tw-beach"
}

data "aws_availability_zones" "azs" {
  state = "available"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.prefix}-test-vpc"
  cidr = "10.0.0.0/16"

  azs = data.aws_availability_zones.azs.names
  database_subnets = ["10.0.30.0/24"]
  private_subnets = ["10.0.20.0/24", "10.0.21.0/24", "10.0.22.0/24"]
  public_subnets = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24", "10.0.100.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false

  create_database_subnet_group = false
  create_database_nat_gateway_route = false
  create_database_subnet_route_table = true

  tags = {
    Owner = "lu"
  }
}

module "public_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name = "${var.prefix}-public-sg"
  description = "security-group for web tier"
  vpc_id = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      description = "internal"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
    {
      from_port   = 22
      to_port     = 80
      protocol    = "tcp"
      description = "ssh and nginx port"
      cidr_blocks = var.my-ip
    },
    {
      from_port   = 8000
      to_port     = 10000
      protocol    = "tcp"
      description = "Service name"
      cidr_blocks = var.my-ip
    }
    ]

    egress_with_cidr_blocks = [
      {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      description = "egress"
      cidr_blocks = "0.0.0.0/0"
    }
    ]
}

module "private_sg" {
  source = "terraform-aws-modules/security-group/aws"
  
  name = "${var.prefix}-private-sg"
  description = "security-group for app tier"
  vpc_id = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      description = "internal"
      cidr_blocks = module.vpc.vpc_cidr_block
    }
    ]

    egress_with_cidr_blocks = [
      {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      description = "egress"
      cidr_blocks = "0.0.0.0/0"
    }
    ]
}

module "db_sg" {
  source = "terraform-aws-modules/security-group/aws"
  
  name = "${var.prefix}-db-sg"
  description = "security-group for db tier"
  vpc_id = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 20000
      protocol    = "tcp"
      description = "internal"
      cidr_blocks = module.vpc.vpc_cidr_block
    }
    ]

    egress_with_cidr_blocks = [
      {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      description = "internal"
      cidr_blocks = module.vpc.vpc_cidr_block
    }
    ]
}

module "web_autoscaling" {
  source = "./modules/web-ec2-autoscaling"

  prefix = var.prefix
  subnets = slice(module.vpc.public_subnets, 0, 3)
  ami = var.ami
  security_groups = [module.public_sg.security_group_id]
  key_name = "lu-aws"
  resource_tags = {
    Owner = "lu"
  }
}

module "app_autoscaling" {
  source = "./modules/app-ec2-autoscaling"

  prefix = var.prefix
  vpc_id = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  public_subnets = module.vpc.public_subnets
  ami = var.ami
  private_security_groups = [module.private_sg.security_group_id]
  public_security_groups = [module.public_sg.security_group_id]
  key_name = "lu-aws"
  resource_tags = {
    Owner = "lu"
    tier = "app"
  }
}

module "pipeline" {
  source = "./modules/pipeline"

  prefix = var.prefix
  public_subnets = module.vpc.public_subnets
  ami = var.ami
  public_security_groups = [module.public_sg.security_group_id]
  Owner = "lu"
}


