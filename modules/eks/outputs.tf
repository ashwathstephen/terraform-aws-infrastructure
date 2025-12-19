#------------------------------------------------------------------------------
# EKS Module - Outputs
#------------------------------------------------------------------------------

output "cluster_id" {
  description = "The ID of the EKS cluster"
  value       = aws_eks_cluster.this.id
}

output "cluster_arn" {
  description = "The ARN of the EKS cluster"
  value       = aws_eks_cluster.this.arn
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.this.name
}

output "cluster_version" {
  description = "The Kubernetes version of the cluster"
  value       = aws_eks_cluster.this.version
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster API server"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data for the cluster"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_security_group.cluster.id
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster"
  value       = aws_iam_role.cluster.arn
}

output "cluster_oidc_issuer_url" {
  description = "The URL of the OpenID Connect identity provider"
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "cluster_oidc_provider_arn" {
  description = "The ARN of the OIDC Provider"
  value       = aws_iam_openid_connect_provider.cluster.arn
}

output "node_group_role_arn" {
  description = "IAM role ARN for the node groups"
  value       = aws_iam_role.node_group.arn
}

output "node_groups" {
  description = "Map of node group attributes"
  value = {
    for k, v in aws_eks_node_group.this : k => {
      arn           = v.arn
      status        = v.status
      capacity_type = v.capacity_type
    }
  }
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for secrets encryption"
  value       = var.cluster_encryption_key_arn != "" ? var.cluster_encryption_key_arn : try(aws_kms_key.cluster[0].arn, null)
}

output "kubeconfig_command" {
  description = "Command to update kubeconfig"
  value       = "aws eks update-kubeconfig --name ${aws_eks_cluster.this.name} --region <region>"
}

