locals {
  alarms = merge({
    unhealthy      = { namespace = "AWS/ApplicationELB", metric = "UnHealthyHostCount", statistic = "Maximum", threshold = 0, comparison = "GreaterThanThreshold", dimensions = { LoadBalancer = var.load_balancer_arn_suffix, TargetGroup = var.target_group_arn_suffix } },
    server_errors  = { namespace = "AWS/ApplicationELB", metric = "HTTPCode_Target_5XX_Count", statistic = "Sum", threshold = 10, comparison = "GreaterThanOrEqualToThreshold", dimensions = { LoadBalancer = var.load_balancer_arn_suffix, TargetGroup = var.target_group_arn_suffix } },
    database_space = { namespace = "AWS/RDS", metric = "FreeStorageSpace", statistic = "Minimum", threshold = 5368709120, comparison = "LessThanThreshold", dimensions = { DBInstanceIdentifier = var.database_identifier } }
    }, var.service_name == null ? {} : {
    cpu    = { namespace = "AWS/ECS", metric = "CPUUtilization", statistic = "Average", threshold = 85, comparison = "GreaterThanThreshold", dimensions = { ClusterName = var.cluster_name, ServiceName = var.service_name } },
    memory = { namespace = "AWS/ECS", metric = "MemoryUtilization", statistic = "Average", threshold = 85, comparison = "GreaterThanThreshold", dimensions = { ClusterName = var.cluster_name, ServiceName = var.service_name } }
  })
}
resource "aws_cloudwatch_metric_alarm" "application" {
  for_each            = local.alarms
  alarm_name          = "${var.name}-${each.key}"
  namespace           = each.value.namespace
  metric_name         = each.value.metric
  statistic           = each.value.statistic
  dimensions          = each.value.dimensions
  period              = 300
  evaluation_periods  = 2
  threshold           = each.value.threshold
  comparison_operator = each.value.comparison
  treat_missing_data  = "notBreaching"
  alarm_actions       = var.alarm_action_arns
  ok_actions          = var.alarm_action_arns
}
