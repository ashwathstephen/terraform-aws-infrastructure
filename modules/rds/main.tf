#------------------------------------------------------------------------------
# RDS Module - Production-Ready Database
# Author: Ashwath Abraham Stephen
#------------------------------------------------------------------------------

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}

#------------------------------------------------------------------------------
# Random Password for Master User
#------------------------------------------------------------------------------

resource "random_password" "master" {
  count = var.master_password == "" ? 1 : 0

  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

#------------------------------------------------------------------------------
# DB Subnet Group
#------------------------------------------------------------------------------

resource "aws_db_subnet_group" "this" {
  name        = "${var.identifier}-subnet-group"
  description = "Subnet group for ${var.identifier}"
  subnet_ids  = var.subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.identifier}-subnet-group"
    }
  )
}

#------------------------------------------------------------------------------
# Security Group
#------------------------------------------------------------------------------

resource "aws_security_group" "this" {
  name        = "${var.identifier}-sg"
  description = "Security group for ${var.identifier}"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.port
    to_port         = var.port
    protocol        = "tcp"
    cidr_blocks     = var.allowed_cidr_blocks
    security_groups = var.allowed_security_groups
    description     = "Database access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.identifier}-sg"
    }
  )
}

#------------------------------------------------------------------------------
# Parameter Group
#------------------------------------------------------------------------------

resource "aws_db_parameter_group" "this" {
  count = var.create_parameter_group ? 1 : 0

  name        = "${var.identifier}-params"
  family      = var.parameter_group_family
  description = "Parameter group for ${var.identifier}"

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", "pending-reboot")
    }
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

#------------------------------------------------------------------------------
# Option Group (for SQL Server, Oracle)
#------------------------------------------------------------------------------

resource "aws_db_option_group" "this" {
  count = var.create_option_group ? 1 : 0

  name                     = "${var.identifier}-options"
  option_group_description = "Option group for ${var.identifier}"
  engine_name              = var.engine
  major_engine_version     = var.major_engine_version

  dynamic "option" {
    for_each = var.options
    content {
      option_name = option.value.option_name

      dynamic "option_settings" {
        for_each = lookup(option.value, "option_settings", [])
        content {
          name  = option_settings.value.name
          value = option_settings.value.value
        }
      }
    }
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

#------------------------------------------------------------------------------
# RDS Instance
#------------------------------------------------------------------------------

resource "aws_db_instance" "this" {
  identifier = var.identifier

  engine                = var.engine
  engine_version        = var.engine_version
  instance_class        = var.instance_class
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = true
  kms_key_id            = var.kms_key_arn

  db_name  = var.database_name
  username = var.master_username
  password = var.master_password != "" ? var.master_password : random_password.master[0].result
  port     = var.port

  vpc_security_group_ids = [aws_security_group.this.id]
  db_subnet_group_name   = aws_db_subnet_group.this.name
  parameter_group_name   = var.create_parameter_group ? aws_db_parameter_group.this[0].name : var.parameter_group_name
  option_group_name      = var.create_option_group ? aws_db_option_group.this[0].name : var.option_group_name

  multi_az            = var.multi_az
  publicly_accessible = false
  availability_zone   = var.multi_az ? null : var.availability_zone

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window

  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  deletion_protection        = var.deletion_protection
  skip_final_snapshot        = var.skip_final_snapshot
  final_snapshot_identifier  = var.skip_final_snapshot ? null : "${var.identifier}-final-snapshot"

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null

  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_interval > 0 ? aws_iam_role.monitoring[0].arn : null

  enabled_cloudwatch_logs_exports = var.cloudwatch_logs_exports

  copy_tags_to_snapshot = true

  tags = merge(
    var.tags,
    {
      Name = var.identifier
    }
  )
}

#------------------------------------------------------------------------------
# Enhanced Monitoring IAM Role
#------------------------------------------------------------------------------

resource "aws_iam_role" "monitoring" {
  count = var.monitoring_interval > 0 ? 1 : 0

  name = "${var.identifier}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "monitoring" {
  count = var.monitoring_interval > 0 ? 1 : 0

  role       = aws_iam_role.monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

#------------------------------------------------------------------------------
# Store Password in Secrets Manager
#------------------------------------------------------------------------------

resource "aws_secretsmanager_secret" "this" {
  count = var.store_password_in_secrets_manager ? 1 : 0

  name        = "${var.identifier}-db-credentials"
  description = "Database credentials for ${var.identifier}"

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "this" {
  count = var.store_password_in_secrets_manager ? 1 : 0

  secret_id = aws_secretsmanager_secret.this[0].id
  secret_string = jsonencode({
    username = var.master_username
    password = var.master_password != "" ? var.master_password : random_password.master[0].result
    host     = aws_db_instance.this.address
    port     = var.port
    database = var.database_name
  })
}

