locals {
  name          = "locdoc-${var.environment}"
  secret_prefix = "/${local.name}"
  # ECS selectors carry JSON-key/version suffixes; IAM authorizes the base secret ARN.
  extra_secret_resource_arns = [for arn in values(var.extra_secret_arns) : join(":", slice(split(":", arn), 0, 7))]
}
module "network" {
  source             = "../../../modules/locdoc-network"
  name               = local.name
  region             = var.region
  cidr_block         = var.vpc_cidr
  availability_zones = var.availability_zones
  database_port      = var.database_engine == "postgres" ? 5432 : 3306
}
module "kms" {
  source     = "../../../modules/locdoc-kms"
  name       = local.name
  account_id = var.account_id
  region     = var.region
}
module "oms" {
  source      = "../../../modules/locdoc-oms-aws"
  environment = var.environment
  bucket_name = "${local.name}-${var.account_id}-${var.region}-documents"
  kms_key_arn = module.kms.key_arn
  require_tls = true
}
resource "aws_secretsmanager_secret" "runtime" {
  name                    = "${local.secret_prefix}/runtime"
  kms_key_id              = module.kms.key_arn
  recovery_window_in_days = 30
}
resource "aws_secretsmanager_secret" "database_application" {
  name                    = "${local.secret_prefix}/database-application"
  kms_key_id              = module.kms.key_arn
  recovery_window_in_days = 30
}
module "registry" {
  source = "../../../modules/locdoc-registry"
  name   = local.name
}
module "logs" {
  source      = "../../../modules/locdoc-logs"
  name        = local.name
  account_id  = var.account_id
  kms_key_arn = module.kms.key_arn
  flow_logs   = true
  vpc_id      = module.network.vpc_id
}
module "iam" {
  source                  = "../../../modules/locdoc-iam"
  name                    = local.name
  account_id              = var.account_id
  region                  = var.region
  bucket_arn              = module.oms.documents_bucket_arn
  repository_arn          = module.registry.arn
  log_group_arn           = module.logs.application_log_group_arn
  integration_secret_arns = concat(values(module.oms.secret_arns), [for service in ["stripe", "seclock"] : "arn:aws:secretsmanager:${var.region}:${var.account_id}:secret:oms/${service}/*"])
  runtime_secret_arns     = concat([aws_secretsmanager_secret.runtime.arn, aws_secretsmanager_secret.database_application.arn], local.extra_secret_resource_arns)
  kms_key_arn             = module.kms.key_arn
}
module "database" {
  source                 = "../../../modules/locdoc-database"
  name                   = local.name
  engine                 = var.database_engine
  engine_version         = var.database_engine_version
  parameter_group_family = var.database_parameter_group_family
  subnet_ids             = module.network.database_subnet_ids
  security_group_id      = module.network.database_security_group_id
  kms_key_arn            = module.kms.key_arn
}
module "identity" {
  source = "../../../modules/locdoc-identity"
  name   = local.name
}
module "edge" {
  source                 = "../../../modules/locdoc-edge"
  name                   = local.name
  account_id             = var.account_id
  domain_name            = var.domain_name
  hosted_zone_id         = var.hosted_zone_id
  certificate_arn        = var.certificate_arn
  subnet_ids             = module.network.public_subnet_ids
  security_group_id      = module.network.load_balancer_security_group_id
  vpc_id                 = module.network.vpc_id
  access_log_bucket_name = "${local.name}-${var.account_id}-${var.region}-alb"
}
module "runtime" {
  source                          = "../../../modules/locdoc-runtime"
  name                            = local.name
  region                          = var.region
  repository_url                  = module.registry.repository_url
  image_digest                    = var.image_digest
  service_enabled                 = var.service_enabled
  database_engine                 = var.database_engine
  database_host                   = module.database.address
  database_port                   = module.database.port
  database_name                   = "oms"
  database_application_secret_arn = aws_secretsmanager_secret.database_application.arn
  runtime_secret_arn              = aws_secretsmanager_secret.runtime.arn
  bucket_name                     = module.oms.documents_bucket
  user_pool_client_id             = module.identity.web_client_id
  log_group_name                  = module.logs.application_log_group_name
  application_role_arn            = module.iam.application_role_arn
  execution_role_arn              = module.iam.execution_role_arn
  subnet_ids                      = module.network.application_subnet_ids
  security_group_id               = module.network.application_security_group_id
  target_group_arn                = module.edge.target_group_arn
  extra_environment               = merge(var.extra_environment, { APP_BASE_URL = module.edge.url })
  extra_secret_arns               = var.extra_secret_arns
  depends_on                      = [module.edge, module.iam]
}
output "application_url" { value = module.edge.url }
output "repository_url" { value = module.registry.repository_url }
output "database_master_secret_arn" { value = module.database.master_secret_arn }
output "database_application_secret_arn" { value = aws_secretsmanager_secret.database_application.arn }
output "runtime_secret_arn" { value = aws_secretsmanager_secret.runtime.arn }
output "documents_bucket" { value = module.oms.documents_bucket }
output "user_pool_id" { value = module.identity.user_pool_id }

module "monitoring" {
  source                   = "../../../modules/locdoc-monitoring"
  name                     = local.name
  load_balancer_arn_suffix = module.edge.load_balancer_arn_suffix
  target_group_arn_suffix  = module.edge.target_group_arn_suffix
  database_identifier      = module.database.identifier
  cluster_name             = module.runtime.cluster_name
  # Use the configured name so resource keys are known before apply.
  service_name      = var.service_enabled ? local.name : null
  alarm_action_arns = var.alarm_action_arns
}
