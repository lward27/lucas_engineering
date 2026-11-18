output "target_group_arn" { value = aws_lb_target_group.application.arn }
output "load_balancer_arn_suffix" { value = aws_lb.main.arn_suffix }
output "target_group_arn_suffix" { value = aws_lb_target_group.application.arn_suffix }
output "https_listener_arn" { value = aws_lb_listener.https.arn }
output "url" { value = "https://${var.domain_name}" }
