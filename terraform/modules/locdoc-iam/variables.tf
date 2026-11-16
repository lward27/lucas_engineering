variable "name" { type = string }
variable "account_id" { type = string }
variable "region" { type = string }
variable "bucket_arn" { type = string }
variable "repository_arn" { type = string }
variable "log_group_arn" { type = string }
variable "integration_secret_arns" { type = list(string) }
variable "runtime_secret_arns" {
  type    = list(string)
  default = []
}
variable "kms_key_arn" {
  type    = string
  default = null
}
