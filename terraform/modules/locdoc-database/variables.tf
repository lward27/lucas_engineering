variable "name" { type = string }
variable "engine" {
  type = string
  validation {
    condition     = contains(["postgres", "mysql"], var.engine)
    error_message = "Choose postgres or mysql explicitly; the image must contain the matching Prisma client."
  }
}
variable "engine_version" { type = string }
variable "parameter_group_family" { type = string }
variable "subnet_ids" { type = list(string) }
variable "security_group_id" { type = string }
variable "kms_key_arn" { type = string }
variable "database_name" {
  type    = string
  default = "oms"
}
variable "instance_class" {
  type    = string
  default = "db.t4g.small"
}
variable "max_storage_gb" {
  type    = number
  default = 100
}
