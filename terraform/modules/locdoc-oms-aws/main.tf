terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = ">= 6.20, < 7.0" }
  }
}
variable "environment" { type = string }
variable "bucket_name" { type = string }
variable "secret_names" {
  type    = set(string)
  default = ["oms/precisely/system"]
}
resource "aws_s3_bucket" "documents" {
  bucket = var.bucket_name
  tags   = { Application = "locdoc-oms", Environment = var.environment }
}
resource "aws_s3_bucket_public_access_block" "documents" {
  bucket                  = aws_s3_bucket.documents.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
resource "aws_s3_bucket_versioning" "documents" {
  bucket = aws_s3_bucket.documents.id
  versioning_configuration { status = "Enabled" }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "documents" {
  bucket = aws_s3_bucket.documents.id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}
# Names come from OMS code. Values are supplied separately and never hardcoded
# into this reusable module. The lab disables real tax/payment/supplier calls.
resource "aws_secretsmanager_secret" "application" {
  for_each                = var.secret_names
  name                    = each.value
  recovery_window_in_days = 7
  tags                    = { Application = "locdoc-oms", Environment = var.environment }
}
output "documents_bucket" { value = aws_s3_bucket.documents.id }
output "secret_arns" { value = { for name, secret in aws_secretsmanager_secret.application : name => secret.arn } }
