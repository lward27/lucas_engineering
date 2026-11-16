terraform {
  required_version = ">= 1.6, < 2.0"
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
