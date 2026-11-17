terraform {
  required_version = ">= 1.6, < 2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  # Local state is intentional. Never share this backend/state with AWS.
  backend "local" {}
}

# This root is LOCAL ONLY. Production roots should reuse resource modules,
# with their own provider configuration, credentials, and backend.
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    apigateway     = var.localstack_endpoint
    cloudwatch     = var.localstack_endpoint
    cloudwatchlogs = var.localstack_endpoint
    dynamodb       = var.localstack_endpoint
    ec2            = var.localstack_endpoint
    eventbridge    = var.localstack_endpoint
    iam            = var.localstack_endpoint
    kms            = var.localstack_endpoint
    route53        = var.localstack_endpoint
    s3             = var.localstack_endpoint
    secretsmanager = var.localstack_endpoint
    sfn            = var.localstack_endpoint
    sns            = var.localstack_endpoint
    sqs            = var.localstack_endpoint
    ssm            = var.localstack_endpoint
    sts            = var.localstack_endpoint
  }
}

variable "localstack_endpoint" {
  description = "Loopback port-forward, or the private Kubernetes service endpoint."
  type        = string
  default     = "http://127.0.0.1:4566"
  validation {
    condition = contains([
      "http://127.0.0.1:4566",
      "http://localhost:4566",
      "http://localstack.localstack.svc.cluster.local:4566",
    ], var.localstack_endpoint)
    error_message = "Use the local port-forward or the private LocalStack service."
  }
}

resource "aws_s3_bucket" "documents" {
  bucket = "locdoc-dev-documents"
}

resource "aws_s3_bucket_public_access_block" "documents" {
  bucket                  = aws_s3_bucket.documents.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_sqs_queue" "document_jobs" {
  name                       = "locdoc-dev-document-jobs"
  visibility_timeout_seconds = 60
}

output "documents_bucket" {
  value = aws_s3_bucket.documents.id
}

output "document_jobs_url" {
  value = aws_sqs_queue.document_jobs.url
}
