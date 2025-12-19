#------------------------------------------------------------------------------
# IAM Module - Outputs
#------------------------------------------------------------------------------

output "role_arn" {
  description = "ARN of the IAM role"
  value       = aws_iam_role.this.arn
}

output "role_name" {
  description = "Name of the IAM role"
  value       = aws_iam_role.this.name
}

output "role_id" {
  description = "ID of the IAM role"
  value       = aws_iam_role.this.id
}

output "instance_profile_arn" {
  description = "ARN of the instance profile"
  value       = try(aws_iam_instance_profile.this[0].arn, null)
}

output "instance_profile_name" {
  description = "Name of the instance profile"
  value       = try(aws_iam_instance_profile.this[0].name, null)
}

output "custom_policy_arn" {
  description = "ARN of the custom policy"
  value       = try(aws_iam_policy.custom[0].arn, null)
}

