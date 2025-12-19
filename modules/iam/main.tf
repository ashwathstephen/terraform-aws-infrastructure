#------------------------------------------------------------------------------
# IAM Module - Roles, Policies, and OIDC
# Author: Ashwath Abraham Stephen
#------------------------------------------------------------------------------

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

#------------------------------------------------------------------------------
# IAM Role
#------------------------------------------------------------------------------

resource "aws_iam_role" "this" {
  name                 = var.role_name
  path                 = var.role_path
  max_session_duration = var.max_session_duration
  description          = var.role_description

  assume_role_policy = var.assume_role_policy != "" ? var.assume_role_policy : jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = var.trusted_services
        }
      }
    ]
  })

  permissions_boundary = var.permissions_boundary_arn

  tags = var.tags
}

#------------------------------------------------------------------------------
# Managed Policy Attachments
#------------------------------------------------------------------------------

resource "aws_iam_role_policy_attachment" "managed" {
  for_each = toset(var.managed_policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

#------------------------------------------------------------------------------
# Inline Policies
#------------------------------------------------------------------------------

resource "aws_iam_role_policy" "inline" {
  for_each = var.inline_policies

  name   = each.key
  role   = aws_iam_role.this.id
  policy = each.value
}

#------------------------------------------------------------------------------
# Custom Policy
#------------------------------------------------------------------------------

resource "aws_iam_policy" "custom" {
  count = var.create_custom_policy ? 1 : 0

  name        = "${var.role_name}-policy"
  path        = var.role_path
  description = "Custom policy for ${var.role_name}"
  policy      = var.custom_policy_document

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "custom" {
  count = var.create_custom_policy ? 1 : 0

  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.custom[0].arn
}

#------------------------------------------------------------------------------
# Instance Profile (for EC2)
#------------------------------------------------------------------------------

resource "aws_iam_instance_profile" "this" {
  count = var.create_instance_profile ? 1 : 0

  name = "${var.role_name}-profile"
  path = var.role_path
  role = aws_iam_role.this.name

  tags = var.tags
}

