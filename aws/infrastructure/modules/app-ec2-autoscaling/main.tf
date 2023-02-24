module "app_autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"

  name = "${var.prefix}-app-autoscaling"

  min_size = 1
  max_size = 3
  desired_capacity = 1
  wait_for_capacity_timeout = 0
  default_instance_warmup = 300
  health_check_type = "EC2"
  vpc_zone_identifier = var.subnets

  launch_template_name = "${var.prefix}-app-template"
  launch_template_description = "${var.prefix} app machine launch template"

  image_id = var.ami
  instance_type = "t3.micro"
  user_data = filebase64("${path.module}/app_init.sh")
  security_groups = var.security_groups
  key_name = var.key_name

  target_group_arns = module.app_lb.target_group_arns

  block_device_mappings = [
    {
      device_name = "/dev/sda1"

      ebs = {
        volume_size = 12
      }
    }
  ]

  cpu_options = {
    core_count       = 1
    threads_per_core = 2
  }

  network_interfaces = [
    {
      delete_on_termination = true
      description = "eth0"
      device_index = 0
      associate_public_ip_address = false
      security_groups = var.security_groups
    }
  ]

  scaling_policies = {
    avg-cpu-policy-greater-than-50 = {
      policy_type               = "TargetTrackingScaling"
      estimated_instance_warmup = 300
      target_tracking_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ASGAverageCPUUtilization"
        }
        target_value = 50.0
      }
    }
  }

  tags = var.resource_tags
}

module "app_lb" {
  source  = "terraform-aws-modules/alb/aws"

  name = "${var.prefix}-app-internal-load-balancer"
  load_balancer_type = "application"
  internal = true

  vpc_id = var.vpc_id
  security_groups = var.security_groups
  subnets = var.subnets
  
  enable_cross_zone_load_balancing = true

  http_tcp_listeners = [
    {
      port = 80
      protocol = "HTTP"
      target_group_index = 0
      action_type = "forward"
    }
  ]

  target_groups = [
    {
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    }
  ]

}