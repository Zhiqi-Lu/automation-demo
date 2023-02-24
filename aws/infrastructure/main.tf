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
  subnets = module.vpc.private_subnets
  ami = var.ami
  security_groups = [module.private_sg.security_group_id]
  key_name = "lu-aws"
  resource_tags = {
    Owner = "lu"
    tier = "app"
  }
}

module "app_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  name = "${var.prefix}-app-apigateway"
  protocol_type = "HTTP"
  create_api_domain_name = false

  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  integrations = {
    "GET /clients" = {
      integration_type = "HTTP_PROXY"
      integration_uri = module.app_autoscaling.http_tcp_listener_arns[0]
      integration_method = "ANY"
      connection_type = "VPC_LINK"
      vpc_link = "my-vpc"
    }
  }

  vpc_links = {
    my-vpc = {
      name               = "${var.prefix}-api-gateway-vpc-link"
      security_group_ids = [module.public_sg.security_group_id]
      subnet_ids         = module.vpc.public_subnets
    }
  }

  
}

