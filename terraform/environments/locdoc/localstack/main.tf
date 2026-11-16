terraform {
  required_version = ">= 1.10, < 2.0"
  required_providers { aws = { source = "hashicorp/aws", version = "6.20.0" } }
  backend "local" {}
}
provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  s3_use_path_style           = true
  access_key                  = "test"
  secret_key                  = "test"
  skip_requesting_account_id  = true
  endpoints {
    s3             = "http://127.0.0.1:4566"
    sts            = "http://127.0.0.1:4566"
    iam            = "http://127.0.0.1:4566"
    secretsmanager = "http://127.0.0.1:4566"
    kms            = "http://127.0.0.1:4566"
    sqs            = "http://127.0.0.1:4566"
    sns            = "http://127.0.0.1:4566"
    dynamodb       = "http://127.0.0.1:4566"
    ssm            = "http://127.0.0.1:4566"
    eventbridge    = "http://127.0.0.1:4566"
    cloudwatch     = "http://127.0.0.1:4566"
    cloudwatchlogs = "http://127.0.0.1:4566"
    sfn            = "http://127.0.0.1:4566"
    ec2            = "http://127.0.0.1:4566"
    route53        = "http://127.0.0.1:4566"
    apigateway     = "http://127.0.0.1:4566"
  }
}
module "oms" {
  source      = "../../../modules/locdoc-oms-aws"
  environment = "localstack"
  bucket_name = "locdoc-oms-localstack-documents"
}
output "documents_bucket" { value = module.oms.documents_bucket }
output "secret_arns" { value = module.oms.secret_arns }

# API-model tests only: the Kubernetes OMS still uses its own PostgreSQL and network.
module "network" {
  source              = "../../../modules/locdoc-network"
  name                = "locdoc-oms-localstack"
  region              = "us-east-1"
  cidr_block          = "10.80.0.0/16"
  availability_zones  = ["us-east-1a", "us-east-1b"]
  nat_mode            = "none"
  s3_gateway_endpoint = false
  # Preserve the existing empty-account provider identities; explicitly qualify SG references.
  security_group_reference_account_id = "000000000000"
}
module "logs" {
  source     = "../../../modules/locdoc-logs"
  name       = "locdoc-oms-localstack"
  account_id = "000000000000"
}
module "iam" {
  source                  = "../../../modules/locdoc-iam"
  name                    = "locdoc-oms-localstack"
  region                  = "us-east-1"
  account_id              = "000000000000"
  bucket_arn              = module.oms.documents_bucket_arn
  repository_arn          = "arn:aws:ecr:us-east-1:000000000000:repository/locdoc-oms-localstack"
  log_group_arn           = module.logs.application_log_group_arn
  integration_secret_arns = values(module.oms.secret_arns)
}
output "vpc_id" { value = module.network.vpc_id }
output "application_role_arn" { value = module.iam.application_role_arn }
