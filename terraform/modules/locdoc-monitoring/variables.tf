variable "name" { type = string }
variable "load_balancer_arn_suffix" { type = string }
variable "target_group_arn_suffix" { type = string }
variable "database_identifier" { type = string }
variable "cluster_name" { type = string }
variable "service_name" {
  type    = string
  default = null
}
variable "alarm_action_arns" {
  type    = list(string)
  default = []
}
