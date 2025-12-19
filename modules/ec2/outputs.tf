#------------------------------------------------------------------------------
# EC2 Module - Outputs
#------------------------------------------------------------------------------

output "instance_ids" {
  description = "List of instance IDs"
  value       = aws_instance.this[*].id
}

output "instance_arns" {
  description = "List of instance ARNs"
  value       = aws_instance.this[*].arn
}

output "private_ips" {
  description = "List of private IP addresses"
  value       = aws_instance.this[*].private_ip
}

output "public_ips" {
  description = "List of public IP addresses"
  value       = aws_instance.this[*].public_ip
}

output "private_dns" {
  description = "List of private DNS names"
  value       = aws_instance.this[*].private_dns
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.this.id
}

output "iam_role_arn" {
  description = "IAM role ARN"
  value       = try(aws_iam_role.this[0].arn, null)
}

output "iam_instance_profile_name" {
  description = "IAM instance profile name"
  value       = try(aws_iam_instance_profile.this[0].name, null)
}

