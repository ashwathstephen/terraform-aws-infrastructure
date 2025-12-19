#------------------------------------------------------------------------------
# IAM Module - Variables
#------------------------------------------------------------------------------

variable "role_name" {
  description = "Name of the IAM role"
  type        = string
}

variable "role_description" {
  description = "Description of the IAM role"
  type        = string
  default     = ""
}

variable "role_path" {
  description = "Path for the IAM role"
  type        = string
  default     = "/"
}

variable "max_session_duration" {
  description = "Maximum session duration in seconds"
  type        = number
  default     = 3600
}

variable "assume_role_policy" {
  description = "Custom assume role policy JSON (overrides trusted_services)"
  type        = string
  default     = ""
}

variable "trusted_services" {
  description = "List of AWS services that can assume this role"
  type        = list(string)
  default     = ["ec2.amazonaws.com"]
}

variable "managed_policy_arns" {
  description = "List of managed policy ARNs to attach"
  type        = list(string)
  default     = []
}

variable "inline_policies" {
  description = "Map of inline policy names to policy documents"
  type        = map(string)
  default     = {}
}

variable "create_custom_policy" {
  description = "Create a custom IAM policy"
  type        = bool
  default     = false
}

variable "custom_policy_document" {
  description = "Custom policy document JSON"
  type        = string
  default     = ""
}

variable "create_instance_profile" {
  description = "Create an instance profile for EC2"
  type        = bool
  default     = false
}

variable "permissions_boundary_arn" {
  description = "ARN of the permissions boundary policy"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

