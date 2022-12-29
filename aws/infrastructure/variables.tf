variable "prefix" {
  description = "the environment depoyed in, e.g. dev, qa, prod"
}

variable "my-ip" {
  description = "ip whitelist, e.g. vpn ip address"
}

variable "ami" {
  description = "ec2 instance ami id"
}