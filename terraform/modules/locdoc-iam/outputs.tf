output "application_role_arn" { value = aws_iam_role.application.arn }
output "execution_role_arn" { value = aws_iam_role.execution.arn }
output "application_policy" { value = aws_iam_role_policy.application.policy }

output "execution_policy" { value = aws_iam_role_policy.execution.policy }
