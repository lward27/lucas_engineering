resource "aws_db_subnet_group" "main" {
  name       = var.name
  subnet_ids = var.subnet_ids
}
resource "aws_db_parameter_group" "main" {
  name   = var.name
  family = var.parameter_group_family
  parameter {
    name         = var.engine == "postgres" ? "rds.force_ssl" : "require_secure_transport"
    value        = "1"
    apply_method = "pending-reboot"
  }
}
resource "aws_db_instance" "main" {
  identifier                      = var.name
  engine                          = var.engine
  engine_version                  = var.engine_version
  instance_class                  = var.instance_class
  db_name                         = var.database_name
  username                        = "oms_admin"
  manage_master_user_password     = true
  allocated_storage               = 20
  max_allocated_storage           = var.max_storage_gb
  storage_type                    = "gp3"
  storage_encrypted               = true
  kms_key_id                      = var.kms_key_arn
  db_subnet_group_name            = aws_db_subnet_group.main.name
  vpc_security_group_ids          = [var.security_group_id]
  parameter_group_name            = aws_db_parameter_group.main.name
  port                            = var.engine == "postgres" ? 5432 : 3306
  publicly_accessible             = false
  multi_az                        = true
  backup_retention_period         = 14
  backup_window                   = "05:00-06:00"
  maintenance_window              = "sun:06:00-sun:07:00"
  auto_minor_version_upgrade      = true
  allow_major_version_upgrade     = false
  apply_immediately               = false
  copy_tags_to_snapshot           = true
  deletion_protection             = true
  skip_final_snapshot             = false
  final_snapshot_identifier       = "${var.name}-final"
  enabled_cloudwatch_logs_exports = var.engine == "postgres" ? ["postgresql", "upgrade"] : ["error"]
  lifecycle { prevent_destroy = true }
}
