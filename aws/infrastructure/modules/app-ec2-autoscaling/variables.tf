variable "prefix" {
  description = "the environment depoyed in, e.g. dev, qa, prod"
}

variable "vpc_id" {
  description = "vpc id"
  type = string
}

variable "private_subnets" {
  description = "the subnets to launch resources in, note that subnets also determines availability zones"
  type = list(string)
}

variable "public_subnets" {
  description = "the subnets to launch api gateway in"
  type = list(string)
}

variable "private_security_groups" {
  description = "the security groups to associate with the auto scaling group"
  type = list(string)
}

variable "public_security_groups" {
  description = "the security groups to associate with api gateway"
  type = list(string)
}

variable "ami" {
  description = "ami of the ec2 instance launched"
  type = string
}

variable "key_name" {
  description = "the name of the key pair to use"
  type = string
}

variable "resource_tags" {
  description = "the tags to apply to resources during launch"
  type = map(string)
  default = {}
}