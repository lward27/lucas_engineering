locals {
  zones     = { for index, zone in var.availability_zones : zone => index }
  nat_zones = var.nat_mode == "none" ? {} : (var.nat_mode == "single" ? { (var.availability_zones[0]) = 0 } : local.zones)
}
resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = var.name }
}
resource "aws_internet_gateway" "main" { vpc_id = aws_vpc.main.id }
resource "aws_subnet" "public" {
  for_each                = local.zones
  vpc_id                  = aws_vpc.main.id
  availability_zone       = each.key
  cidr_block              = cidrsubnet(var.cidr_block, 8, each.value)
  map_public_ip_on_launch = false
  tags                    = { Name = "${var.name}-public-${each.key}" }
}
resource "aws_subnet" "application" {
  for_each          = local.zones
  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(var.cidr_block, 8, each.value + 16)
  tags              = { Name = "${var.name}-app-${each.key}" }
}
resource "aws_subnet" "database" {
  for_each          = local.zones
  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(var.cidr_block, 8, each.value + 32)
  tags              = { Name = "${var.name}-db-${each.key}" }
}
resource "aws_route_table" "public" { vpc_id = aws_vpc.main.id }
resource "aws_route" "internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}
resource "aws_route_table_association" "public" {
  for_each       = local.zones
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}
resource "aws_eip" "nat" {
  for_each = local.nat_zones
  domain   = "vpc"
}
resource "aws_nat_gateway" "main" {
  for_each      = local.nat_zones
  subnet_id     = aws_subnet.public[each.key].id
  allocation_id = aws_eip.nat[each.key].id
  depends_on    = [aws_internet_gateway.main]
}
resource "aws_route_table" "application" {
  for_each = local.zones
  vpc_id   = aws_vpc.main.id
}
resource "aws_route" "application_nat" {
  for_each               = var.nat_mode == "none" ? {} : local.zones
  route_table_id         = aws_route_table.application[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[var.nat_mode == "single" ? var.availability_zones[0] : each.key].id
}
resource "aws_route_table_association" "application" {
  for_each       = local.zones
  subnet_id      = aws_subnet.application[each.key].id
  route_table_id = aws_route_table.application[each.key].id
}
resource "aws_route_table" "database" { vpc_id = aws_vpc.main.id }
resource "aws_route_table_association" "database" {
  for_each       = local.zones
  subnet_id      = aws_subnet.database[each.key].id
  route_table_id = aws_route_table.database.id
}
resource "aws_vpc_endpoint" "s3" {
  count             = var.s3_gateway_endpoint ? 1 : 0
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [for table in aws_route_table.application : table.id]
}
resource "aws_security_group" "load_balancer" {
  count       = var.security_groups_enabled ? 1 : 0
  name        = "${var.name}-alb"
  description = "HTTPS ingress; application traffic only on egress"
  vpc_id      = aws_vpc.main.id
}
resource "aws_security_group" "application" {
  count       = var.security_groups_enabled ? 1 : 0
  name        = "${var.name}-app"
  description = "OMS receives traffic only from its load balancer"
  vpc_id      = aws_vpc.main.id
}
resource "aws_security_group" "database" {
  count       = var.security_groups_enabled ? 1 : 0
  name        = "${var.name}-db"
  description = "Database receives traffic only from OMS tasks"
  vpc_id      = aws_vpc.main.id
}
resource "aws_vpc_security_group_ingress_rule" "https" {
  for_each          = var.security_groups_enabled ? toset(var.https_ingress_cidrs) : toset([])
  security_group_id = aws_security_group.load_balancer[0].id
  cidr_ipv4         = each.value
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}
resource "aws_vpc_security_group_egress_rule" "alb_application" {
  count                        = var.security_groups_enabled ? 1 : 0
  security_group_id            = aws_security_group.load_balancer[0].id
  referenced_security_group_id = var.security_group_reference_account_id == null ? aws_security_group.application[0].id : "${var.security_group_reference_account_id}/${aws_security_group.application[0].id}"
  ip_protocol                  = "tcp"
  from_port                    = var.application_port
  to_port                      = var.application_port
}
resource "aws_vpc_security_group_ingress_rule" "application" {
  count                        = var.security_groups_enabled ? 1 : 0
  security_group_id            = aws_security_group.application[0].id
  referenced_security_group_id = var.security_group_reference_account_id == null ? aws_security_group.load_balancer[0].id : "${var.security_group_reference_account_id}/${aws_security_group.load_balancer[0].id}"
  ip_protocol                  = "tcp"
  from_port                    = var.application_port
  to_port                      = var.application_port
}
resource "aws_vpc_security_group_egress_rule" "database" {
  count                        = var.security_groups_enabled ? 1 : 0
  security_group_id            = aws_security_group.application[0].id
  referenced_security_group_id = var.security_group_reference_account_id == null ? aws_security_group.database[0].id : "${var.security_group_reference_account_id}/${aws_security_group.database[0].id}"
  ip_protocol                  = "tcp"
  from_port                    = var.database_port
  to_port                      = var.database_port
}
resource "aws_vpc_security_group_ingress_rule" "database" {
  count                        = var.security_groups_enabled ? 1 : 0
  security_group_id            = aws_security_group.database[0].id
  referenced_security_group_id = var.security_group_reference_account_id == null ? aws_security_group.application[0].id : "${var.security_group_reference_account_id}/${aws_security_group.application[0].id}"
  ip_protocol                  = "tcp"
  from_port                    = var.database_port
  to_port                      = var.database_port
}
resource "aws_vpc_security_group_egress_rule" "external_tls" {
  for_each          = var.security_groups_enabled ? toset(["443", "587"]) : toset([])
  security_group_id = aws_security_group.application[0].id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = tonumber(each.value)
  to_port           = tonumber(each.value)
}

resource "aws_vpc_security_group_ingress_rule" "http_redirect" {
  for_each          = var.security_groups_enabled ? toset(var.https_ingress_cidrs) : toset([])
  security_group_id = aws_security_group.load_balancer[0].id
  cidr_ipv4         = each.value
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

moved {
  from = aws_vpc_security_group_egress_rule.alb_application
  to   = aws_vpc_security_group_egress_rule.alb_application[0]
}

moved {
  from = aws_vpc_security_group_ingress_rule.application
  to   = aws_vpc_security_group_ingress_rule.application[0]
}

moved {
  from = aws_vpc_security_group_egress_rule.database
  to   = aws_vpc_security_group_egress_rule.database[0]
}

moved {
  from = aws_vpc_security_group_ingress_rule.database
  to   = aws_vpc_security_group_ingress_rule.database[0]
}

moved {
  from = aws_security_group.load_balancer
  to   = aws_security_group.load_balancer[0]
}

moved {
  from = aws_security_group.application
  to   = aws_security_group.application[0]
}

moved {
  from = aws_security_group.database
  to   = aws_security_group.database[0]
}
