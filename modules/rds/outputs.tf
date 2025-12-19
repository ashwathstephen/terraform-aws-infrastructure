#------------------------------------------------------------------------------
# RDS Module - Outputs
#------------------------------------------------------------------------------

output "db_instance_id" {
  description = "The RDS instance ID"
  value       = aws_db_instance.this.id
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.this.arn
}

output "db_instance_address" {
  description = "The hostname of the RDS instance"
  value       = aws_db_instance.this.address
}

output "db_instance_endpoint" {
  description = "The connection endpoint"
  value       = aws_db_instance.this.endpoint
}

output "db_instance_port" {
  description = "The database port"
  value       = aws_db_instance.this.port
}

output "db_instance_name" {
  description = "The database name"
  value       = aws_db_instance.this.db_name
}

output "db_instance_username" {
  description = "The master username"
  value       = aws_db_instance.this.username
  sensitive   = true
}

output "db_subnet_group_name" {
  description = "The DB subnet group name"
  value       = aws_db_subnet_group.this.name
}

output "db_security_group_id" {
  description = "The security group ID"
  value       = aws_security_group.this.id
}

output "db_parameter_group_name" {
  description = "The parameter group name"
  value       = try(aws_db_parameter_group.this[0].name, var.parameter_group_name)
}

output "secrets_manager_secret_arn" {
  description = "ARN of the Secrets Manager secret"
  value       = try(aws_secretsmanager_secret.this[0].arn, null)
}

