output "vpc_id" { value = aws_vpc.main.id }
output "public_subnet_ids" { value = [for zone, subnet in aws_subnet.public : subnet.id] }
output "application_subnet_ids" { value = [for zone, subnet in aws_subnet.application : subnet.id] }
output "database_subnet_ids" { value = [for zone, subnet in aws_subnet.database : subnet.id] }
output "load_balancer_security_group_id" { value = var.security_groups_enabled ? aws_security_group.load_balancer[0].id : null }
output "application_security_group_id" { value = var.security_groups_enabled ? aws_security_group.application[0].id : null }
output "database_security_group_id" { value = var.security_groups_enabled ? aws_security_group.database[0].id : null }
