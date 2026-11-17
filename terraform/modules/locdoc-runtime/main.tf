locals {
  environment = merge(var.extra_environment, {
    NODE_ENV                    = "production", ENV_TYPE = "production", DEV = "false", PORT = "8080",
    OMS_MOCK_S3                 = "false", OMS_MOCK_STRIPE = "false", OMS_MOCK_SECLOCK = "false", OMS_MOCK_MAPS = "false",
    AWS_REGION                  = var.region, AWS_BUCKET_NAME = var.bucket_name,
    AWS_USER_POOL_WEB_CLIENT_ID = var.user_pool_client_id,
    AWS_ACCESS_KEY_ID           = "", AWS_SECRET_ACCESS_KEY = "", AWS_ENDPOINT_URL = "", AWS_ENDPOINT_URL_S3 = "",
    AWS_EC2_METADATA_DISABLED   = "true", DATABASE_PROVIDER = var.database_engine,
    DB_HOST                     = var.database_host, DB_PORT = tostring(var.database_port), DB_NAME = var.database_name,
    DB_SSL_ROOT_CERT            = "/etc/ssl/certs/rds-ca.pem"
  })
  container = {
    name         = "oms", essential = true, image = var.image_digest == null ? null : "${var.repository_url}@${var.image_digest}",
    user         = "1000:1000", workingDirectory = "/app", readonlyRootFilesystem = true,
    entryPoint   = ["node", "-e"], command = [file("${path.module}/bootstrap.cjs")],
    portMappings = [{ containerPort = 8080, hostPort = 8080, protocol = "tcp" }],
    environment  = [for name, value in local.environment : { name = name, value = value }],
    secrets = concat([
      { name = "DB_USER", valueFrom = "${var.database_application_secret_arn}:username::" },
      { name = "DB_PASSWORD", valueFrom = "${var.database_application_secret_arn}:password::" },
      { name = "TOKEN_SECRET", valueFrom = "${var.runtime_secret_arn}:token_secret::" },
      { name = "REFRESH_TOKEN_SECRET", valueFrom = "${var.runtime_secret_arn}:refresh_token_secret::" }
    ], [for name, arn in var.extra_secret_arns : { name = name, valueFrom = arn }]),
    logConfiguration = { logDriver = "awslogs", options = { "awslogs-group" = var.log_group_name, "awslogs-region" = var.region, "awslogs-stream-prefix" = "oms" } },
    linuxParameters  = { initProcessEnabled = true, capabilities = { drop = ["ALL"] } },
    stopTimeout      = 120,
    mountPoints      = [{ sourceVolume = "uploads", containerPath = "/app/uploads", readOnly = false }, { sourceVolume = "logs", containerPath = "/app/dist/logs", readOnly = false }, { sourceVolume = "tmp", containerPath = "/tmp", readOnly = false }]
  }
}
resource "aws_ecs_cluster" "main" {
  name = var.name
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
resource "aws_ecs_task_definition" "application" {
  count                    = var.image_digest == null ? 0 : 1
  family                   = var.name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "1024"
  memory                   = "4096"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.application_role_arn
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  container_definitions = jsonencode([local.container])
  volume { name = "uploads" }
  volume { name = "logs" }
  volume { name = "tmp" }
}
resource "aws_ecs_service" "application" {
  count            = var.service_enabled ? 1 : 0
  name             = var.name
  cluster          = aws_ecs_cluster.main.id
  task_definition  = try(aws_ecs_task_definition.application[0].arn, "")
  launch_type      = "FARGATE"
  platform_version = "1.4.0"
  # Current Socket.IO rooms and background process state are in memory.
  desired_count                      = 1
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100
  wait_for_steady_state              = true
  enable_execute_command             = false
  health_check_grace_period_seconds  = 90
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "oms"
    container_port   = 8080
  }
  lifecycle {
    precondition {
      condition     = var.image_digest != null
      error_message = "Publish an approved immutable image before enabling the service."
    }
  }
}
