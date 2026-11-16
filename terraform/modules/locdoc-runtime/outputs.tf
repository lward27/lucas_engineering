output "cluster_name" { value = aws_ecs_cluster.main.name }
output "service_name" { value = var.service_enabled ? aws_ecs_service.application[0].name : null }
output "container_configuration" { value = local.container }
