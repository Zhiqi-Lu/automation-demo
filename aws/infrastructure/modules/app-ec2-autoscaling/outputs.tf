output "http_tcp_listener_arns" {
  description = "http_tcp_listener_arns of the load balancer"
  value = module.app_lb.http_tcp_listener_arns
}