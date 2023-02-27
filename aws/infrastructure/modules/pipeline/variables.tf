variable "prefix" {
  description = "the environment depoyed in, e.g. dev, qa, prod"
}

variable "public_subnet" {
  description = "the subnets to launch api gateway in"
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

variable "Owner" {
  description = "owner tag"
  type = string
}