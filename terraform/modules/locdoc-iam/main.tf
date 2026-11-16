locals {
  trust = jsonencode({ Version = "2012-10-17", Statement = [{ Effect = "Allow", Action = "sts:AssumeRole", Principal = { Service = "ecs-tasks.amazonaws.com" }, Condition = {
  StringEquals = { "aws:SourceAccount" = var.account_id }, ArnLike = { "aws:SourceArn" = "arn:aws:ecs:${var.region}:${var.account_id}:*" } } }] })
}
resource "aws_iam_role" "application" {
  name               = "${var.name}-application"
  assume_role_policy = local.trust
}
resource "aws_iam_role_policy" "application" {
  name = "application-data"
  role = aws_iam_role.application.id
  policy = jsonencode({ Version = "2012-10-17", Statement = concat([
    { Sid = "DocumentListing", Effect = "Allow", Action = ["s3:ListBucket", "s3:GetBucketLocation"], Resource = var.bucket_arn },
    { Sid = "DocumentObjects", Effect = "Allow", Action = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject", "s3:AbortMultipartUpload"], Resource = "${var.bucket_arn}/*" },
    { Sid = "IntegrationSecrets", Effect = "Allow", Action = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"], Resource = var.integration_secret_arns }
  ], var.kms_key_arn == null ? [] : [{ Sid = "ApplicationDataKey", Effect = "Allow", Action = ["kms:Decrypt", "kms:Encrypt", "kms:GenerateDataKey", "kms:DescribeKey"], Resource = var.kms_key_arn }]) })
}
resource "aws_iam_role" "execution" {
  name               = "${var.name}-execution"
  assume_role_policy = local.trust
}
resource "aws_iam_role_policy" "execution" {
  name = "task-startup"
  role = aws_iam_role.execution.id
  policy = jsonencode({ Version = "2012-10-17", Statement = concat([
    # ECR authentication does not support repository-scoped resources.
    { Sid = "RegistryAuthentication", Effect = "Allow", Action = ["ecr:GetAuthorizationToken"], Resource = "*" },
    { Sid = "ReleaseImages", Effect = "Allow", Action = ["ecr:BatchCheckLayerAvailability", "ecr:GetDownloadUrlForLayer", "ecr:BatchGetImage"], Resource = var.repository_arn },
    { Sid = "TaskLogs", Effect = "Allow", Action = ["logs:CreateLogStream", "logs:PutLogEvents"], Resource = "${var.log_group_arn}:*" }
    ], length(var.runtime_secret_arns) == 0 ? [] : [{ Sid = "InjectedSecrets", Effect = "Allow", Action = ["secretsmanager:GetSecretValue"], Resource = var.runtime_secret_arns }],
  var.kms_key_arn == null ? [] : [{ Sid = "InjectedSecretKey", Effect = "Allow", Action = ["kms:Decrypt"], Resource = var.kms_key_arn }]) })
}
