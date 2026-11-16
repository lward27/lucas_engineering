terraform {
  required_version = ">= 1.6, < 2.0"
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
