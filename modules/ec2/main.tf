#------------------------------------------------------------------------------
# EC2 Module - Production-Ready EC2 Instances
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
# Data Sources
#------------------------------------------------------------------------------

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

#------------------------------------------------------------------------------
# Security Group
#------------------------------------------------------------------------------

resource "aws_security_group" "this" {
  name        = "${var.name}-sg"
  description = "Security group for ${var.name}"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      cidr_blocks     = lookup(ingress.value, "cidr_blocks", null)
      security_groups = lookup(ingress.value, "security_groups", null)
      description     = lookup(ingress.value, "description", null)
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-sg"
    }
  )
}

#------------------------------------------------------------------------------
# IAM Role for EC2 (SSM Access)
#------------------------------------------------------------------------------

resource "aws_iam_role" "this" {
  count = var.create_iam_role ? 1 : 0

  name = "${var.name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ssm" {
  count = var.create_iam_role ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  count = var.create_iam_role && var.enable_cloudwatch_agent ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "this" {
  count = var.create_iam_role ? 1 : 0

  name = "${var.name}-profile"
  role = aws_iam_role.this[0].name

  tags = var.tags
}

#------------------------------------------------------------------------------
# EC2 Instance
#------------------------------------------------------------------------------

resource "aws_instance" "this" {
  count = var.instance_count

  ami                    = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_ids[count.index % length(var.subnet_ids)]
  vpc_security_group_ids = [aws_security_group.this.id]
  key_name               = var.key_name
  iam_instance_profile   = var.create_iam_role ? aws_iam_instance_profile.this[0].name : var.iam_instance_profile

  associate_public_ip_address = var.associate_public_ip

  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    encrypted             = true
    delete_on_termination = true

    tags = merge(
      var.tags,
      {
        Name = "${var.name}-root-${count.index + 1}"
      }
    )
  }

  dynamic "ebs_block_device" {
    for_each = var.ebs_volumes
    content {
      device_name           = ebs_block_device.value.device_name
      volume_type           = lookup(ebs_block_device.value, "volume_type", "gp3")
      volume_size           = ebs_block_device.value.volume_size
      encrypted             = true
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", true)
    }
  }

  user_data = var.user_data

  monitoring = var.enable_detailed_monitoring

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  tags = merge(
    var.tags,
    {
      Name = var.instance_count > 1 ? "${var.name}-${count.index + 1}" : var.name
    }
  )

  lifecycle {
    ignore_changes = [ami]
  }
}

#------------------------------------------------------------------------------
# CloudWatch Alarms for Auto-Recovery
#------------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "auto_recovery" {
  count = var.enable_auto_recovery ? var.instance_count : 0

  alarm_name          = "${var.name}-${count.index + 1}-auto-recovery"
  alarm_description   = "Auto-recovery alarm for ${var.name}-${count.index + 1}"
  namespace           = "AWS/EC2"
  metric_name         = "StatusCheckFailed_System"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  period              = 60
  statistic           = "Maximum"
  threshold           = 0

  dimensions = {
    InstanceId = aws_instance.this[count.index].id
  }

  alarm_actions = [
    "arn:aws:automate:${data.aws_region.current.name}:ec2:recover"
  ]

  tags = var.tags
}

data "aws_region" "current" {}

