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
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_key_arn == null ? "AES256" : "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
  }
}
# Names come from OMS code. Values are supplied separately and never hardcoded
# into this reusable module. The lab disables real tax/payment/supplier calls.
resource "aws_secretsmanager_secret" "application" {
  for_each                = var.secret_names
  name                    = each.value
  recovery_window_in_days = 30
  kms_key_id              = var.kms_key_arn
  tags                    = { Application = "locdoc-oms", Environment = var.environment }
}
output "documents_bucket" { value = aws_s3_bucket.documents.bucket }
output "secret_arns" { value = { for name, secret in aws_secretsmanager_secret.application : name => secret.arn } }

variable "kms_key_arn" {
  type    = string
  default = null
}
variable "require_tls" {
  type    = bool
  default = false
}
resource "aws_s3_bucket_policy" "tls" {
  count  = var.require_tls ? 1 : 0
  bucket = aws_s3_bucket.documents.id
  policy = jsonencode({ Version = "2012-10-17", Statement = [{ Sid = "RequireTLS", Effect = "Deny", Principal = "*", Action = "s3:*", Resource = [aws_s3_bucket.documents.arn, "${aws_s3_bucket.documents.arn}/*"], Condition = { Bool = { "aws:SecureTransport" = "false" } } }] })
}
output "documents_bucket_arn" { value = aws_s3_bucket.documents.arn }
