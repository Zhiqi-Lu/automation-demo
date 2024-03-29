resource "aws_instance" "jenkins_controller" {
  ami = var.ami
  instance_type = "t3.small"
  key_name = "lu-aws"
  subnet_id = var.public_subnet
  vpc_security_group_ids = var.public_security_groups
  private_ip = "10.0.100.10"
  user_data = filebase64("${path.module}/app_init.sh")

  tags = {
    Name = "${var.prefix}-joi-jenkins-controller"
    Owner = var.Owner
  }
}

resource "aws_instance" "jenkins_agent1" {
  ami = var.ami
  instance_type = "t3.small"
  key_name = "lu-aws"
  subnet_id = var.public_subnet
  vpc_security_group_ids = var.public_security_groups
  private_ip = "10.0.100.11"
  user_data = filebase64("${path.module}/app_init.sh")

  tags = {
    Name = "${var.prefix}-joi-jenkins-agent"
    Owner = var.Owner
  }
}

# resource "aws_instance" "sonarqube" {
#   ami = var.ami
#   instance_type = "t3.medium"
#   key_name = "lu-aws"
#   subnet_id = var.public_subnet
#   vpc_security_group_ids = var.public_security_groups
#   private_ip = "10.0.100.20"
#   tags = {
#     Name = "${var.prefix}-sonarqube"
#     Owner = var.Owner
#   }
# }

resource "aws_instance" "nexus_repo" {
  ami = var.ami
  instance_type = "t3.medium"
  key_name = "lu-aws"
  subnet_id = var.public_subnet
  vpc_security_group_ids = var.public_security_groups
  private_ip = "10.0.100.30"
  user_data = filebase64("${path.module}/app_init.sh")

  root_block_device {
    volume_size = 20
  }

  tags = {
    Name = "${var.prefix}-nexus"
    Owner = var.Owner
  }
}

resource "aws_instance" "harbor" {
  ami = var.ami
  instance_type = "t3.medium"
  key_name = "lu-aws"
  subnet_id = var.public_subnet
  vpc_security_group_ids = var.public_security_groups
  private_ip = "10.0.100.40"
  user_data = filebase64("${path.module}/app_init.sh")

  root_block_device {
    volume_size = 20
  }

  tags = {
    Name = "${var.prefix}-harbor"
    Owner = var.Owner
  }
}