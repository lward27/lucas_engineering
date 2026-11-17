variable "name" { type = string }
variable "region" { type = string }
variable "repository_url" { type = string }
variable "image_digest" {
  type    = string
  default = null
  validation {
    condition     = var.image_digest == null ? true : can(regex("^sha256:[0-9a-f]{64}$", var.image_digest))
    error_message = "Use an immutable sha256 image digest, not a tag."
  }
}
variable "service_enabled" {
  type    = bool
  default = false
}
variable "database_engine" { type = string }
variable "database_host" { type = string }
variable "database_port" { type = number }
variable "database_name" { type = string }
variable "database_application_secret_arn" { type = string }
variable "runtime_secret_arn" { type = string }
variable "bucket_name" { type = string }
variable "user_pool_client_id" { type = string }
variable "log_group_name" { type = string }
variable "application_role_arn" { type = string }
variable "execution_role_arn" { type = string }
variable "subnet_ids" { type = list(string) }
variable "security_group_id" { type = string }
variable "target_group_arn" { type = string }
variable "extra_environment" {
  type    = map(string)
  default = {}
  validation {
    condition     = alltrue([for name in keys(var.extra_environment) : !can(regex("(?i)(password|secret|token|credential|api.?key)", name)) && !startswith(name, "AWS_")])
    error_message = "Supply sensitive settings through Secrets Manager injection, not Terraform environment values."
  }
}

variable "extra_secret_arns" {
  type    = map(string)
  default = {}
  validation {
    condition     = alltrue([for name, arn in var.extra_secret_arns : !startswith(name, "AWS_") && can(regex("^arn:aws:secretsmanager:[a-z0-9-]+:[0-9]{12}:secret:", arn)) && !contains(["DB_USER", "DB_PASSWORD", "TOKEN_SECRET", "REFRESH_TOKEN_SECRET"], name) && !contains(["NODE_ENV", "ENV_TYPE", "DEV", "PORT", "AWS_REGION", "AWS_BUCKET_NAME", "AWS_USER_POOL_WEB_CLIENT_ID", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY", "AWS_ENDPOINT_URL", "AWS_ENDPOINT_URL_S3", "AWS_EC2_METADATA_DISABLED", "DATABASE_PROVIDER", "DATABASE_URL", "DB_HOST", "DB_PORT", "DB_NAME", "DB_SSL_ROOT_CERT", "OMS_MOCK_S3", "OMS_MOCK_STRIPE", "OMS_MOCK_SECLOCK", "OMS_MOCK_MAPS"], name)])
    error_message = "Use Secrets Manager ARNs and do not override managed runtime settings."
  }
}
