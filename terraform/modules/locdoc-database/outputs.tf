output "address" { value = aws_db_instance.main.address }
output "port" { value = aws_db_instance.main.port }
output "identifier" { value = aws_db_instance.main.identifier }
# ARN only. RDS generates/rotates the master password outside Terraform state.
output "master_secret_arn" { value = aws_db_instance.main.master_user_secret[0].secret_arn }
