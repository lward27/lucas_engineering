resource "aws_cloudwatch_log_group" "application" {
  name              = "/locdoc/${var.name}/application"
  retention_in_days = var.retention_days
  kms_key_id        = var.kms_key_arn
}
resource "aws_cloudwatch_log_group" "flow" {
  count             = var.flow_logs ? 1 : 0
  name              = "/locdoc/${var.name}/vpc-flow"
  retention_in_days = var.retention_days
  kms_key_id        = var.kms_key_arn
}
resource "aws_iam_role" "flow" {
  count              = var.flow_logs ? 1 : 0
  name               = "${var.name}-vpc-flow"
  assume_role_policy = jsonencode({ Version = "2012-10-17", Statement = [{ Effect = "Allow", Action = "sts:AssumeRole", Principal = { Service = "vpc-flow-logs.amazonaws.com" }, Condition = { StringEquals = { "aws:SourceAccount" = var.account_id } } }] })
}
resource "aws_iam_role_policy" "flow" {
  count = var.flow_logs ? 1 : 0
  role  = aws_iam_role.flow[0].id
  policy = jsonencode({ Version = "2012-10-17", Statement = [{ Effect = "Allow", Action = ["logs:CreateLogStream", "logs:PutLogEvents", "logs:DescribeLogStreams"], Resource = "${aws_cloudwatch_log_group.flow[0].arn}:*" },
    # DescribeLogGroups does not support resource-level authorization.
    { Effect = "Allow", Action = ["logs:DescribeLogGroups"], Resource = "*" }
  ] })
}
resource "aws_flow_log" "vpc" {
  count           = var.flow_logs ? 1 : 0
  vpc_id          = var.vpc_id
  traffic_type    = "ALL"
  iam_role_arn    = aws_iam_role.flow[0].arn
  log_destination = aws_cloudwatch_log_group.flow[0].arn
  depends_on      = [aws_iam_role_policy.flow]
}
