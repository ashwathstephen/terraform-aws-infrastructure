#------------------------------------------------------------------------------
# Example: EKS Cluster with VPC
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

provider "aws" {
  region = var.region
}

# VPC for EKS
module "vpc" {
  source = "../../modules/vpc"

  name               = "${var.cluster_name}-vpc"
  cidr               = "10.0.0.0/16"
  availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]

  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

# EKS Cluster
module "eks" {
  source = "../../modules/eks"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  node_groups = {
    general = {
      instance_types = ["t3.medium"]
      min_size       = 2
      max_size       = 5
      desired_size   = 3
      capacity_type  = "ON_DEMAND"
    }

    spot = {
      instance_types = ["t3.medium", "t3.large"]
      min_size       = 0
      max_size       = 10
      desired_size   = 2
      capacity_type  = "SPOT"
      labels = {
        "workload-type" = "spot"
      }
      taints = [
        {
          key    = "spot"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      ]
    }
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "cluster_name" {
  type    = string
  default = "my-eks-cluster"
}

variable "environment" {
  type    = string
  default = "development"
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "kubeconfig_command" {
  value = module.eks.kubeconfig_command
}

