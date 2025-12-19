#------------------------------------------------------------------------------
# EC2 Module - Variables
#------------------------------------------------------------------------------

variable "name" {
  description = "Name prefix for all resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the instances"
  type        = list(string)
}

variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 1
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID (leave empty to use latest Amazon Linux 2023)"
  type        = string
  default     = ""
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = null
}

variable "associate_public_ip" {
  description = "Associate a public IP address"
  type        = bool
  default     = false
}

variable "root_volume_type" {
  description = "Root volume type"
  type        = string
  default     = "gp3"
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 20
}

variable "ebs_volumes" {
  description = "List of additional EBS volumes"
  type = list(object({
    device_name           = string
    volume_size           = number
    volume_type           = optional(string, "gp3")
    delete_on_termination = optional(bool, true)
  }))
  default = []
}

variable "user_data" {
  description = "User data script"
  type        = string
  default     = null
}

variable "ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string))
    security_groups = optional(list(string))
    description     = optional(string)
  }))
  default = []
}

variable "create_iam_role" {
  description = "Create an IAM role for the instance"
  type        = bool
  default     = true
}

variable "iam_instance_profile" {
  description = "Existing IAM instance profile name (if not creating new)"
  type        = string
  default     = null
}

variable "enable_cloudwatch_agent" {
  description = "Enable CloudWatch agent permissions"
  type        = bool
  default     = true
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring"
  type        = bool
  default     = true
}

variable "enable_auto_recovery" {
  description = "Enable automatic instance recovery"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

