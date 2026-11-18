terraform {
  required_version = ">= 1.10, < 2.0"
  required_providers { aws = { source = "hashicorp/aws", version = "6.20.0" } }
  backend "local" {}
}
variable "account_id" { type = string }
variable "region" { type = string }
variable "bucket_name" { type = string }
provider "aws" {
  region              = var.region
  allowed_account_ids = [var.account_id]
}
module "state" {
  source      = "../../../modules/locdoc-state"
  bucket_name = var.bucket_name
}
output "bucket_name" { value = module.state.bucket_name }
