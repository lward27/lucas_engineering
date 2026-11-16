variable "account_id" {
  type = string
  validation {
    condition     = can(regex("^[0-9]{12}$", var.account_id))
    error_message = "Supply the intended twelve-digit AWS account ID."
  }
}
variable "region" {
  type    = string
  default = "us-east-1"
}
variable "environment" {
  type    = string
  default = "production"
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,14}$", var.environment))
    error_message = "Use a short lowercase environment name (maximum 15 characters)."
  }
}
variable "availability_zones" { type = list(string) }
variable "vpc_cidr" {
  type    = string
  default = "10.90.0.0/16"
}
variable "domain_name" { type = string }
variable "hosted_zone_id" { type = string }
variable "certificate_arn" {
  type    = string
  default = null
}
variable "database_engine" { type = string }
variable "database_engine_version" { type = string }
variable "database_parameter_group_family" { type = string }
variable "image_digest" {
  type    = string
  default = null
}
variable "service_enabled" {
  type    = bool
  default = false
}
variable "extra_environment" {
  type    = map(string)
  default = {}
}

variable "extra_secret_arns" {
  type    = map(string)
  default = {}
}
variable "alarm_action_arns" {
  type    = list(string)
  default = []
}
