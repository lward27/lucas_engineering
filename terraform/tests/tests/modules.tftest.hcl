mock_provider "aws" {
  mock_resource "aws_acm_certificate" {
    defaults = {
      arn                       = "arn:aws:acm:us-east-1:111122223333:certificate/12345678-1234-1234-1234-123456789012"
      domain_validation_options = [{ domain_name = "oms.example.com", resource_record_name = "_validation.oms.example.com", resource_record_type = "CNAME", resource_record_value = "_token.acm-validations.aws." }]
    }
  }
  mock_resource "aws_acm_certificate_validation" {
    defaults = { certificate_arn = "arn:aws:acm:us-east-1:111122223333:certificate/12345678-1234-1234-1234-123456789012" }
  }

  override_during = plan
  mock_resource "aws_vpc" {
    defaults = { "id" : "vpc-12345678" }
  }
  mock_resource "aws_subnet" {
    defaults = { "id" : "subnet-12345678" }
  }
  mock_resource "aws_security_group" {
    defaults = { "id" : "sg-12345678" }
  }
  mock_resource "aws_kms_key" {
    defaults = { "arn" : "arn:aws:kms:us-east-1:111122223333:key/12345678-1234-1234-1234-123456789012", "key_id" : "12345678-1234-1234-1234-123456789012" }
  }
  mock_resource "aws_s3_bucket" {
    defaults = { "id" : "locdoc-test", "arn" : "arn:aws:s3:::locdoc-test" }
  }
  mock_resource "aws_cloudwatch_log_group" {
    defaults = { "arn" : "arn:aws:logs:us-east-1:111122223333:log-group:/locdoc/locdoc-test/application" }
  }
  mock_resource "aws_iam_role" {
    defaults = { "arn" : "arn:aws:iam::111122223333:role/locdoc-test" }
  }
  mock_resource "aws_secretsmanager_secret" {
    defaults = { "arn" : "arn:aws:secretsmanager:us-east-1:111122223333:secret:locdoc-test-AbCdEf" }
  }
  mock_resource "aws_ecr_repository" {
    defaults = { "arn" : "arn:aws:ecr:us-east-1:111122223333:repository/locdoc-test", "repository_url" : "111122223333.dkr.ecr.us-east-1.amazonaws.com/locdoc-test" }
  }
  mock_resource "aws_db_instance" {
    defaults = { "address" : "db.test.us-east-1.rds.amazonaws.com", "master_user_secret" : [{ "secret_arn" : "arn:aws:secretsmanager:us-east-1:111122223333:secret:locdoc-test-AbCdEf", "secret_status" : "active", "kms_key_id" : "arn:aws:kms:us-east-1:111122223333:key/12345678-1234-1234-1234-123456789012" }] }
  }
  mock_resource "aws_lb" {
    defaults = { "arn" : "arn:aws:elasticloadbalancing:us-east-1:111122223333:loadbalancer/app/locdoc-test/1234567890123456", "dns_name" : "test.elb.amazonaws.com", "zone_id" : "Z35SXDOTRQ7X7K" }
  }
  mock_resource "aws_lb_target_group" {
    defaults = { "arn" : "arn:aws:elasticloadbalancing:us-east-1:111122223333:targetgroup/locdoc-test/1234567890123456" }
  }
  mock_resource "aws_ecs_cluster" {
    defaults = { "id" : "arn:aws:ecs:us-east-1:111122223333:cluster/locdoc-test" }
  }
  mock_resource "aws_ecs_task_definition" {
    defaults = { "arn" : "arn:aws:ecs:us-east-1:111122223333:task-definition/locdoc-test:1" }
  }
}
run "private_network" {
  command = plan
  module { source = "../modules/locdoc-network" }
  variables {
    name               = "locdoc-test"
    region             = "us-east-1"
    cidr_block         = "10.80.0.0/16"
    availability_zones = ["us-east-1a", "us-east-1b"]
  }
  assert {
    condition     = length(aws_subnet.application) == 2 && length(aws_subnet.database) == 2
    error_message = "Keep application and database subnets in two AZs."
  }
  assert {
    condition     = length(aws_nat_gateway.main) == 2 && length(aws_route.application_nat) == 2
    error_message = "Production needs per-AZ NAT egress."
  }
  assert {
    condition     = alltrue([for subnet in aws_subnet.public : !subnet.map_public_ip_on_launch])
    error_message = "No subnet automatically assigns public IPs."
  }
  assert {
    condition     = aws_vpc_security_group_ingress_rule.database[0].from_port == 5432 && aws_vpc_security_group_ingress_rule.database[0].referenced_security_group_id == aws_security_group.application[0].id
    error_message = "Only application tasks can reach the database."
  }

}
run "emulated_network" {
  command = plan
  module { source = "../modules/locdoc-network" }
  variables {
    name                    = "locdoc-test"
    region                  = "us-east-1"
    cidr_block              = "10.80.0.0/16"
    availability_zones      = ["us-east-1a", "us-east-1b"]
    nat_mode                = "none"
    s3_gateway_endpoint     = false
    security_groups_enabled = false
  }
  assert {
    condition     = length(aws_nat_gateway.main) == 0 && length(aws_route.application_nat) == 0 && length(aws_vpc_endpoint.s3) == 0 && length(aws_security_group.application) == 0
    error_message = "Lab control-plane topology must not create managed egress."
  }
}
run "rotating_data_key" {
  command = plan
  module { source = "../modules/locdoc-kms" }
  variables {
    name       = "locdoc-test"
    account_id = "111122223333"
    region     = "us-east-1"
  }
  assert {
    condition     = aws_kms_key.data.enable_key_rotation && aws_kms_key.data.deletion_window_in_days == 30
    error_message = "Rotate data keys and allow a 30-day deletion recovery window."
  }
}
run "private_storage" {
  command = plan
  module { source = "../modules/locdoc-oms-aws" }
  variables {
    environment = "test"
    bucket_name = "locdoc-test"
    kms_key_arn = "arn:aws:kms:us-east-1:111122223333:key/12345678-1234-1234-1234-123456789012"
    require_tls = true
  }
  assert {
    condition     = aws_s3_bucket_public_access_block.documents.block_public_policy && aws_s3_bucket_public_access_block.documents.restrict_public_buckets
    error_message = "Document storage stays private."
  }
  assert {
    condition     = one(aws_s3_bucket_versioning.documents.versioning_configuration).status == "Enabled"
    error_message = "Keep object versions."
  }
  assert {
    condition     = one(one(aws_s3_bucket_server_side_encryption_configuration.documents.rule).apply_server_side_encryption_by_default).sse_algorithm == "aws:kms"
    error_message = "AWS documents use the customer data key."
  }
  assert {
    condition     = jsondecode(aws_s3_bucket_policy.tls[0].policy).Statement[0].Effect == "Deny"
    error_message = "Deny insecure transport."
  }
}
run "immutable_registry" {
  command = plan
  module { source = "../modules/locdoc-registry" }
  variables {
    name = "locdoc-test"
  }
  assert {
    condition     = aws_ecr_repository.application.image_tag_mutability == "IMMUTABLE" && !aws_ecr_repository.application.force_delete
    error_message = "Never mutate a release tag or force-delete release images."
  }
}
run "encrypted_audit_logs" {
  command = plan
  module { source = "../modules/locdoc-logs" }
  variables {
    name        = "locdoc-test"
    account_id  = "111122223333"
    kms_key_arn = "arn:aws:kms:us-east-1:111122223333:key/12345678-1234-1234-1234-123456789012"
    flow_logs   = true
    vpc_id      = "vpc-12345678"
  }
  assert {
    condition     = aws_cloudwatch_log_group.application.retention_in_days == 30 && aws_cloudwatch_log_group.application.kms_key_id == var.kms_key_arn && aws_flow_log.vpc[0].traffic_type == "ALL"
    error_message = "Retain encrypted application and network evidence."
  }
}
run "postgres_database" {
  command = plan
  module { source = "../modules/locdoc-database" }
  variables {
    name                   = "locdoc-test"
    engine                 = "postgres"
    engine_version         = "17.6"
    parameter_group_family = "postgres17"
    subnet_ids             = ["subnet-12345678", "subnet-87654321"]
    security_group_id      = "sg-12345678"
    kms_key_arn            = "arn:aws:kms:us-east-1:111122223333:key/12345678-1234-1234-1234-123456789012"
  }
  assert {
    condition     = aws_db_instance.main.multi_az && !aws_db_instance.main.publicly_accessible && aws_db_instance.main.storage_encrypted
    error_message = "Database is private, encrypted and redundant."
  }
  assert {
    condition     = aws_db_instance.main.manage_master_user_password && aws_db_instance.main.password == null
    error_message = "Terraform must not receive a database password."
  }
  assert {
    condition     = aws_db_instance.main.deletion_protection && !aws_db_instance.main.skip_final_snapshot && aws_db_instance.main.backup_retention_period == 14
    error_message = "Protect the database and retain backups."
  }
  assert {
    condition     = one(aws_db_parameter_group.main.parameter).name == "rds.force_ssl" && one(aws_db_parameter_group.main.parameter).value == "1"
    error_message = "PostgreSQL requires TLS."
  }
}
run "mysql_database" {
  command = plan
  module { source = "../modules/locdoc-database" }
  variables {
    name                   = "locdoc-test"
    engine                 = "mysql"
    engine_version         = "8.4.7"
    parameter_group_family = "mysql8.4"
    subnet_ids             = ["subnet-12345678", "subnet-87654321"]
    security_group_id      = "sg-12345678"
    kms_key_arn            = "arn:aws:kms:us-east-1:111122223333:key/12345678-1234-1234-1234-123456789012"
  }
  assert {
    condition     = aws_db_instance.main.multi_az && !aws_db_instance.main.publicly_accessible && aws_db_instance.main.storage_encrypted
    error_message = "Database is private, encrypted and redundant."
  }
  assert {
    condition     = aws_db_instance.main.manage_master_user_password && aws_db_instance.main.password == null
    error_message = "Terraform must not receive a database password."
  }
  assert {
    condition     = aws_db_instance.main.deletion_protection && !aws_db_instance.main.skip_final_snapshot && aws_db_instance.main.backup_retention_period == 14
    error_message = "Protect the database and retain backups."
  }
  assert {
    condition     = one(aws_db_parameter_group.main.parameter).name == "require_secure_transport" && aws_db_instance.main.port == 3306
    error_message = "MySQL requires TLS on its own port."
  }
}
run "public_cognito_client" {
  command = plan
  module { source = "../modules/locdoc-identity" }
  variables {
    name = "locdoc-test"
  }
  assert {
    condition     = !aws_cognito_user_pool_client.web.generate_secret && aws_cognito_user_pool_client.web.enable_token_revocation
    error_message = "Browser client cannot hold a client secret; revoke refresh tokens."
  }
  assert {
    condition     = aws_cognito_user_pool.main.mfa_configuration == "OPTIONAL" && aws_cognito_user_pool.main.deletion_protection == "ACTIVE"
    error_message = "Preserve users and support app TOTP enrollment."
  }
}
run "role_separation" {
  command = plan
  module { source = "../modules/locdoc-iam" }
  variables {
    name                    = "locdoc-test"
    region                  = "us-east-1"
    account_id              = "111122223333"
    bucket_arn              = "arn:aws:s3:::locdoc-test"
    repository_arn          = "arn:aws:ecr:us-east-1:111122223333:repository/locdoc-test"
    log_group_arn           = "arn:aws:logs:us-east-1:111122223333:log-group:/locdoc/locdoc-test/application"
    integration_secret_arns = ["arn:aws:secretsmanager:us-east-1:111122223333:secret:locdoc-test-AbCdEf"]
    runtime_secret_arns     = ["arn:aws:secretsmanager:us-east-1:111122223333:secret:locdoc-test-AbCdEf"]
    kms_key_arn             = "arn:aws:kms:us-east-1:111122223333:key/12345678-1234-1234-1234-123456789012"
  }
  assert {
    condition     = alltrue([for st in jsondecode(aws_iam_role_policy.application.policy).Statement : st.Resource != "*"])
    error_message = "Application permissions are resource scoped."
  }
  assert {
    condition     = jsondecode(aws_iam_role_policy.application.policy).Statement[1].Resource == "arn:aws:s3:::locdoc-test/*"
    error_message = "Document access is scoped to this bucket."
  }
  assert {
    condition     = !strcontains(aws_iam_role_policy.application.policy, "ecr:") && !strcontains(aws_iam_role_policy.application.policy, "CreateSecret")
    error_message = "Application role cannot pull images or write credentials."
  }
  assert {
    condition     = jsondecode(aws_iam_role.application.assume_role_policy).Statement[0].Condition.StringEquals["aws:SourceAccount"] == var.account_id
    error_message = "Task trust is account-scoped."
  }
}
run "https_edge" {
  command = plan
  module { source = "../modules/locdoc-edge" }
  variables {
    name                   = "locdoc-test"
    account_id             = "111122223333"
    domain_name            = "oms.example.com"
    hosted_zone_id         = "Z1234567890123"
    subnet_ids             = ["subnet-12345678", "subnet-87654321"]
    security_group_id      = "sg-12345678"
    vpc_id                 = "vpc-12345678"
    access_log_bucket_name = "locdoc-test-alb"
    certificate_arn        = "arn:aws:acm:us-east-1:111122223333:certificate/12345678-1234-1234-1234-123456789012"
  }
  assert {
    condition     = aws_lb.main.enable_deletion_protection && one(aws_lb.main.access_logs).enabled
    error_message = "Protect and audit the public edge."
  }
  assert {
    condition     = one(one(aws_lb_listener.http.default_action).redirect).protocol == "HTTPS" && aws_lb_listener.https.port == 443
    error_message = "Redirect plaintext requests to TLS."
  }
  assert {
    condition     = aws_lb_target_group.application.target_type == "ip" && one(aws_lb_target_group.application.health_check).path == "/api/health"
    error_message = "Fargate targets require IP registration and OMS health checks."
  }
}
run "launch_disabled_until_ready" {
  command = plan
  module { source = "../modules/locdoc-runtime" }
  variables {
    name                            = "locdoc-test"
    region                          = "us-east-1"
    repository_url                  = "111122223333.dkr.ecr.us-east-1.amazonaws.com/locdoc-test"
    database_engine                 = "postgres"
    database_host                   = "db.test.us-east-1.rds.amazonaws.com"
    database_port                   = 5432
    database_name                   = "oms"
    database_application_secret_arn = "arn:aws:secretsmanager:us-east-1:111122223333:secret:locdoc-test-AbCdEf"
    runtime_secret_arn              = "arn:aws:secretsmanager:us-east-1:111122223333:secret:locdoc-test-AbCdEf"
    bucket_name                     = "locdoc-test"
    user_pool_client_id             = "public-client"
    log_group_name                  = "/locdoc/locdoc-test/application"
    application_role_arn            = "arn:aws:iam::111122223333:role/locdoc-test"
    execution_role_arn              = "arn:aws:iam::111122223333:role/locdoc-test"
    subnet_ids                      = ["subnet-12345678", "subnet-87654321"]
    security_group_id               = "sg-12345678"
    target_group_arn                = "arn:aws:elasticloadbalancing:us-east-1:111122223333:targetgroup/locdoc-test/1234567890123456"
  }
  assert {
    condition     = length(aws_ecs_task_definition.application) == 0 && length(aws_ecs_service.application) == 0
    error_message = "No placeholder image or application launch by default."
  }
}
run "fargate_service" {
  command = plan
  module { source = "../modules/locdoc-runtime" }
  variables {
    name                            = "locdoc-test"
    region                          = "us-east-1"
    repository_url                  = "111122223333.dkr.ecr.us-east-1.amazonaws.com/locdoc-test"
    database_engine                 = "postgres"
    database_host                   = "db.test.us-east-1.rds.amazonaws.com"
    database_port                   = 5432
    database_name                   = "oms"
    database_application_secret_arn = "arn:aws:secretsmanager:us-east-1:111122223333:secret:locdoc-test-AbCdEf"
    runtime_secret_arn              = "arn:aws:secretsmanager:us-east-1:111122223333:secret:locdoc-test-AbCdEf"
    bucket_name                     = "locdoc-test"
    user_pool_client_id             = "public-client"
    log_group_name                  = "/locdoc/locdoc-test/application"
    application_role_arn            = "arn:aws:iam::111122223333:role/locdoc-test"
    execution_role_arn              = "arn:aws:iam::111122223333:role/locdoc-test"
    subnet_ids                      = ["subnet-12345678", "subnet-87654321"]
    security_group_id               = "sg-12345678"
    target_group_arn                = "arn:aws:elasticloadbalancing:us-east-1:111122223333:targetgroup/locdoc-test/1234567890123456"
    image_digest                    = "sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    service_enabled                 = true
    extra_environment               = { "DEV" : "true" }
  }
  assert {
    condition     = aws_ecs_service.application[0].desired_count == 1 && aws_ecs_service.application[0].deployment_maximum_percent == 100
    error_message = "In-memory OMS state requires one task, even during deployments."
  }
  assert {
    condition     = !one(aws_ecs_service.application[0].network_configuration).assign_public_ip
    error_message = "Tasks must stay private."
  }
  assert {
    condition     = local.environment.DEV == "false" && local.environment.OMS_MOCK_S3 == "false" && local.environment.AWS_ACCESS_KEY_ID == ""
    error_message = "Lab flags and static AWS credentials must not leak into production."
  }
  assert {
    condition     = length(local.container.secrets) == 4 && local.container.readonlyRootFilesystem && local.container.user == "1000:1000"
    error_message = "Inject credentials at startup into a nonroot container."
  }
  assert {
    condition     = strcontains(aws_ecs_task_definition.application[0].container_definitions, "@sha256:")
    error_message = "Release images must use a digest."
  }
}
run "reject_mutable_image" {
  command = plan
  module { source = "../modules/locdoc-runtime" }
  variables {
    name                            = "locdoc-test"
    region                          = "us-east-1"
    repository_url                  = "111122223333.dkr.ecr.us-east-1.amazonaws.com/locdoc-test"
    database_engine                 = "postgres"
    database_host                   = "db.test.us-east-1.rds.amazonaws.com"
    database_port                   = 5432
    database_name                   = "oms"
    database_application_secret_arn = "arn:aws:secretsmanager:us-east-1:111122223333:secret:locdoc-test-AbCdEf"
    runtime_secret_arn              = "arn:aws:secretsmanager:us-east-1:111122223333:secret:locdoc-test-AbCdEf"
    bucket_name                     = "locdoc-test"
    user_pool_client_id             = "public-client"
    log_group_name                  = "/locdoc/locdoc-test/application"
    application_role_arn            = "arn:aws:iam::111122223333:role/locdoc-test"
    execution_role_arn              = "arn:aws:iam::111122223333:role/locdoc-test"
    subnet_ids                      = ["subnet-12345678", "subnet-87654321"]
    security_group_id               = "sg-12345678"
    target_group_arn                = "arn:aws:elasticloadbalancing:us-east-1:111122223333:targetgroup/locdoc-test/1234567890123456"
    image_digest                    = "latest"
  }
  expect_failures = [var.image_digest]
}
run "reject_plaintext_credentials" {
  command = plan
  module { source = "../modules/locdoc-runtime" }
  variables {
    name                            = "locdoc-test"
    region                          = "us-east-1"
    repository_url                  = "111122223333.dkr.ecr.us-east-1.amazonaws.com/locdoc-test"
    database_engine                 = "postgres"
    database_host                   = "db.test.us-east-1.rds.amazonaws.com"
    database_port                   = 5432
    database_name                   = "oms"
    database_application_secret_arn = "arn:aws:secretsmanager:us-east-1:111122223333:secret:locdoc-test-AbCdEf"
    runtime_secret_arn              = "arn:aws:secretsmanager:us-east-1:111122223333:secret:locdoc-test-AbCdEf"
    bucket_name                     = "locdoc-test"
    user_pool_client_id             = "public-client"
    log_group_name                  = "/locdoc/locdoc-test/application"
    application_role_arn            = "arn:aws:iam::111122223333:role/locdoc-test"
    execution_role_arn              = "arn:aws:iam::111122223333:role/locdoc-test"
    subnet_ids                      = ["subnet-12345678", "subnet-87654321"]
    security_group_id               = "sg-12345678"
    target_group_arn                = "arn:aws:elasticloadbalancing:us-east-1:111122223333:targetgroup/locdoc-test/1234567890123456"
    extra_environment               = { "API_KEY" : "forbidden" }
  }
  expect_failures = [var.extra_environment]
}
run "reject_premature_launch" {
  command = plan
  module { source = "../modules/locdoc-runtime" }
  variables {
    name                            = "locdoc-test"
    region                          = "us-east-1"
    repository_url                  = "111122223333.dkr.ecr.us-east-1.amazonaws.com/locdoc-test"
    database_engine                 = "postgres"
    database_host                   = "db.test.us-east-1.rds.amazonaws.com"
    database_port                   = 5432
    database_name                   = "oms"
    database_application_secret_arn = "arn:aws:secretsmanager:us-east-1:111122223333:secret:locdoc-test-AbCdEf"
    runtime_secret_arn              = "arn:aws:secretsmanager:us-east-1:111122223333:secret:locdoc-test-AbCdEf"
    bucket_name                     = "locdoc-test"
    user_pool_client_id             = "public-client"
    log_group_name                  = "/locdoc/locdoc-test/application"
    application_role_arn            = "arn:aws:iam::111122223333:role/locdoc-test"
    execution_role_arn              = "arn:aws:iam::111122223333:role/locdoc-test"
    subnet_ids                      = ["subnet-12345678", "subnet-87654321"]
    security_group_id               = "sg-12345678"
    target_group_arn                = "arn:aws:elasticloadbalancing:us-east-1:111122223333:targetgroup/locdoc-test/1234567890123456"
    service_enabled                 = true
  }
  expect_failures = [aws_ecs_service.application[0]]
}
run "protected_state" {
  command = plan
  module { source = "../modules/locdoc-state" }
  variables {
    bucket_name = "locdoc-test-state"
  }
  assert {
    condition     = one(aws_s3_bucket_versioning.state.versioning_configuration).status == "Enabled" && aws_s3_bucket_public_access_block.state.block_public_policy
    error_message = "Version and protect remote state."
  }
}

run "managed_dns_certificate" {
  command = plan
  module { source = "../modules/locdoc-edge" }
  variables {
    name                   = "locdoc-test"
    account_id             = "111122223333"
    domain_name            = "oms.example.com"
    hosted_zone_id         = "Z1234567890123"
    subnet_ids             = ["subnet-12345678", "subnet-87654321"]
    security_group_id      = "sg-12345678"
    vpc_id                 = "vpc-12345678"
    access_log_bucket_name = "locdoc-test-alb"
  }
  assert {
    condition     = length(aws_acm_certificate.application) == 1 && aws_route53_record.certificate[0].type == "CNAME"
    error_message = "Provision and validate a managed certificate when none is supplied."
  }
}
run "operational_alarms" {
  command = plan
  module { source = "../modules/locdoc-monitoring" }
  variables {
    name                     = "locdoc-test"
    load_balancer_arn_suffix = "app/locdoc-test/1234567890123456"
    target_group_arn_suffix  = "targetgroup/locdoc-test/1234567890123456"
    database_identifier      = "locdoc-test"
    cluster_name             = "locdoc-test"
    service_name             = "locdoc-test"
    alarm_action_arns        = ["arn:aws:sns:us-east-1:111122223333:operators"]
  }
  assert {
    condition     = length(aws_cloudwatch_metric_alarm.application) == 5 && aws_cloudwatch_metric_alarm.application["database_space"].threshold == 5368709120 && length(aws_cloudwatch_metric_alarm.application["cpu"].alarm_actions) == 1
    error_message = "Connect service, database and edge alarms to the configured notification target."
  }
}
run "aws_composition" {
  command = plan
  module { source = "../environments/locdoc/aws" }
  variables {
    account_id                      = "111122223333"
    availability_zones              = ["us-east-1a", "us-east-1b"]
    domain_name                     = "oms.example.com"
    hosted_zone_id                  = "Z1234567890123"
    database_engine                 = "postgres"
    database_engine_version         = "17.6"
    database_parameter_group_family = "postgres17"
    extra_secret_arns               = { GOOGLE_MAPS_API_KEY = "arn:aws:secretsmanager:us-east-1:111122223333:secret:maps-AbCdEf:api_key::" }
  }
  assert {
    condition     = module.runtime.service_name == null && module.oms.documents_bucket == "locdoc-production-111122223333-us-east-1-documents"
    error_message = "Compose a separate account-scoped AWS environment without launching an unprepared app."
  }
  assert {
    condition     = module.runtime.container_configuration.image == null && module.runtime.container_configuration.secrets[0].valueFrom == "${aws_secretsmanager_secret.database_application.arn}:username::"
    error_message = "No fabricated image and no master-user credential injection."
  }
  assert {
    condition     = contains(one([for statement in jsondecode(module.iam.execution_policy).Statement : statement if statement.Sid == "InjectedSecrets"]).Resource, "arn:aws:secretsmanager:us-east-1:111122223333:secret:maps-AbCdEf") && module.runtime.container_configuration.secrets[4].valueFrom == var.extra_secret_arns.GOOGLE_MAPS_API_KEY
    error_message = "Authorize the base secret ARN while preserving the ECS JSON-key selector."
  }
}
