terraform {
  required_version = ">= 1.6, < 2.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # Later providers use S3 Control tagging with an account-prefixed host,
      # which this emulator cannot receive. Keep this compatibility pin local.
      version = "6.20.0"
    }
  }
  backend "local" {}
}

variable "emulator_ca_bundle" {
  description = "Generated CA path; set by ops/aws-emulator/client.py for this Pod."
  type        = string
}

locals {
  endpoint = "https://127.0.0.1:9297"
}

# LOCAL ONLY: credentials and TLS CA come from client.py, in a separate state
# from both LocalStack and AWS. Keep endpoint overrides in this root, not in
# reusable production resource modules.
provider "aws" {
  region                      = "us-east-1"
  custom_ca_bundle            = var.emulator_ca_bundle
  allowed_account_ids         = ["000000000000"]
  skip_metadata_api_check     = true
  skip_credentials_validation = true
  s3_use_path_style           = true
  endpoints {
    apigateway     = local.endpoint
    cloudwatch     = local.endpoint
    cloudwatchlogs = local.endpoint
    dynamodb       = local.endpoint
    ec2            = local.endpoint
    eventbridge    = local.endpoint
    iam            = local.endpoint
    kms            = local.endpoint
    route53        = local.endpoint
    s3             = local.endpoint
    secretsmanager = local.endpoint
    sfn            = local.endpoint
    sns            = local.endpoint
    sqs            = local.endpoint
    ssm            = local.endpoint
    sts            = local.endpoint
  }
}

resource "aws_s3_bucket" "documents" {
  bucket = "emulator-dev-documents"
}

resource "aws_s3_bucket_public_access_block" "documents" {
  bucket                  = aws_s3_bucket.documents.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_sqs_queue" "document_jobs" {
  name                       = "emulator-dev-document-jobs"
  visibility_timeout_seconds = 60
}

resource "aws_dynamodb_table" "documents" {
  name         = "emulator-dev-documents"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  attribute {
    name = "id"
    type = "S"
  }
  on_demand_throughput {
    max_read_request_units  = -1
    max_write_request_units = -1
  }
}

output "documents_bucket" {
  value = aws_s3_bucket.documents.id
}

output "document_jobs_url" {
  value = aws_sqs_queue.document_jobs.url
}

output "documents_table" {
  value = aws_dynamodb_table.documents.name
}
