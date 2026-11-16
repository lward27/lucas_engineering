variable "name" { type = string }
variable "region" { type = string }
variable "cidr_block" { type = string }
variable "availability_zones" {
  type = list(string)
  validation {
    condition     = length(var.availability_zones) >= 2 && length(var.availability_zones) <= 3 && length(toset(var.availability_zones)) == length(var.availability_zones)
    error_message = "Provide two or three distinct availability zones."
  }
}
variable "nat_mode" {
  type    = string
  default = "per_az"
  validation {
    condition     = contains(["none", "single", "per_az"], var.nat_mode)
    error_message = "NAT mode must be none, single, or per_az."
  }
}
variable "application_port" {
  type    = number
  default = 8080
}
variable "database_port" {
  type    = number
  default = 5432
}
variable "https_ingress_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}
variable "s3_gateway_endpoint" {
  type    = bool
  default = true
}

variable "security_groups_enabled" {
  type        = bool
  default     = true
  description = "Disable only for API emulators lacking AWS default-egress behavior; real AWS keeps security groups enabled."
}

variable "security_group_reference_account_id" {
  type        = string
  default     = null
  description = "Optional explicit group-owner prefix for emulators whose provider skips account discovery."
}
