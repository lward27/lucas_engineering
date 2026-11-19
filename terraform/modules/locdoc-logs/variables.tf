variable "name" { type = string }
variable "account_id" { type = string }
variable "retention_days" {
  type    = number
  default = 30
}
variable "kms_key_arn" {
  type    = string
  default = null
}
variable "flow_logs" {
  type    = bool
  default = false
}
variable "vpc_id" {
  type    = string
  default = null
}
