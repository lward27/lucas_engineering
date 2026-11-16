terraform {
  required_version = ">= 1.10, < 2.0"
  required_providers { aws = { source = "hashicorp/aws", version = "6.20.0" } }
  backend "local" {}
}
variable "emulator_ca_bundle" { type = string }
provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  s3_use_path_style           = true
  custom_ca_bundle            = var.emulator_ca_bundle
  endpoints {
    s3             = "https://127.0.0.1:9297"
    sts            = "https://127.0.0.1:9297"
    iam            = "https://127.0.0.1:9297"
    secretsmanager = "https://127.0.0.1:9297"
    kms            = "https://127.0.0.1:9297"
    sqs            = "https://127.0.0.1:9297"
    sns            = "https://127.0.0.1:9297"
    dynamodb       = "https://127.0.0.1:9297"
    ssm            = "https://127.0.0.1:9297"
    eventbridge    = "https://127.0.0.1:9297"
    cloudwatch     = "https://127.0.0.1:9297"
    cloudwatchlogs = "https://127.0.0.1:9297"
    sfn            = "https://127.0.0.1:9297"
    ec2            = "https://127.0.0.1:9297"
    route53        = "https://127.0.0.1:9297"
    apigateway     = "https://127.0.0.1:9297"
  }
}
module "oms" {
  source      = "../../../modules/locdoc-oms-aws"
  environment = "aws-emulator"
  bucket_name = "locdoc-oms-aws-emulator-documents"
}
output "documents_bucket" { value = module.oms.documents_bucket }
output "secret_arns" { value = module.oms.secret_arns }

# API-model tests only: the Kubernetes OMS still uses its own PostgreSQL and network.
module "network" {
  source              = "../../../modules/locdoc-network"
  name                = "locdoc-oms-aws-emulator"
  region              = "us-east-1"
  cidr_block          = "10.81.0.0/16"
  availability_zones  = ["us-east-1a", "us-east-1b"]
  nat_mode            = "none"
  s3_gateway_endpoint = false
  # Emulator 1.0.385 lacks the AWS default egress rule expected by provider create.
  security_groups_enabled = false
}
module "logs" {
  source     = "../../../modules/locdoc-logs"
  name       = "locdoc-oms-aws-emulator"
  account_id = "000000000000"
}
module "iam" {
  source                  = "../../../modules/locdoc-iam"
  name                    = "locdoc-oms-aws-emulator"
  region                  = "us-east-1"
  account_id              = "000000000000"
  bucket_arn              = module.oms.documents_bucket_arn
  repository_arn          = "arn:aws:ecr:us-east-1:000000000000:repository/locdoc-oms-aws-emulator"
  log_group_arn           = module.logs.application_log_group_arn
  integration_secret_arns = values(module.oms.secret_arns)
}
output "vpc_id" { value = module.network.vpc_id }
output "application_role_arn" { value = module.iam.application_role_arn }
