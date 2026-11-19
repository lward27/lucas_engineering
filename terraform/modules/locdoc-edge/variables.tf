variable "name" { type = string }
variable "account_id" { type = string }
variable "domain_name" { type = string }
variable "hosted_zone_id" { type = string }
variable "subnet_ids" { type = list(string) }
variable "security_group_id" { type = string }
variable "vpc_id" { type = string }
variable "access_log_bucket_name" { type = string }
variable "certificate_arn" {
  type    = string
  default = null
}
