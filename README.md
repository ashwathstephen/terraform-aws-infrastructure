# Terraform AWS Infrastructure Modules

[![Terraform](https://img.shields.io/badge/Terraform-1.0+-623CE4?logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Modules-FF9900?logo=amazon-aws)](https://aws.amazon.com/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Production-ready, reusable Terraform modules for AWS infrastructure. Built from real-world experience managing cloud infrastructure at scale.

## 📦 Available Modules

| Module | Description | Features |
|--------|-------------|----------|
| [vpc](./modules/vpc) | Production VPC with multi-AZ setup | Public/Private subnets, NAT Gateway, Flow Logs |
| [eks](./modules/eks) | Managed Kubernetes cluster | Node groups, IRSA, Add-ons, Autoscaling |
| [iam](./modules/iam) | IAM roles and policies | OIDC, Service accounts, Cross-account |
| [ec2](./modules/ec2) | EC2 instances with best practices | Auto-recovery, EBS optimization, SSM |
| [rds](./modules/rds) | RDS database clusters | Multi-AZ, Encryption, Automated backups |
| [s3](./modules/s3) | S3 buckets with security | Versioning, Encryption, Lifecycle policies |

## 🚀 Quick Start

```hcl
module "vpc" {
  source = "github.com/ashwathstephen/terraform-aws-infrastructure//modules/vpc"

  name               = "production"
  cidr               = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  
  enable_nat_gateway = true
  single_nat_gateway = false  # HA setup
  
  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

module "eks" {
  source = "github.com/ashwathstephen/terraform-aws-infrastructure//modules/eks"

  cluster_name    = "production-cluster"
  cluster_version = "1.29"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnet_ids

  node_groups = {
    general = {
      instance_types = ["t3.medium"]
      min_size       = 2
      max_size       = 10
      desired_size   = 3
    }
  }
}
```

## 📁 Repository Structure

```
├── modules/
│   ├── vpc/           # VPC with subnets, NAT, routing
│   ├── eks/           # EKS cluster with node groups
│   ├── iam/           # IAM roles, policies, OIDC
│   ├── ec2/           # EC2 instances
│   ├── rds/           # RDS databases
│   └── s3/            # S3 buckets
├── examples/
│   ├── complete-vpc/  # Full VPC example
│   ├── eks-cluster/   # EKS with VPC
│   └── ec2-instance/  # EC2 with networking
└── scripts/
    ├── validate.sh    # Terraform validation
    └── fmt-check.sh   # Format checking
```

## 🔧 Prerequisites

- Terraform >= 1.0
- AWS CLI configured with appropriate credentials
- AWS account with necessary permissions

## 💡 Best Practices Implemented

- **Security**: All resources use encryption at rest and in transit
- **High Availability**: Multi-AZ deployments by default
- **Cost Optimization**: Right-sized defaults with autoscaling
- **Observability**: CloudWatch metrics and logging enabled
- **Tagging**: Consistent tagging strategy across all resources
- **State Management**: Remote state with S3 and DynamoDB locking

## 🧪 Local Testing

```bash
# Validate all modules
make validate

# Format check
make fmt-check

# Run examples (requires AWS credentials)
make test-vpc
```

## 📝 Examples

See the [examples](./examples) directory for complete, working examples:

- [Complete VPC](./examples/complete-vpc) - Production VPC with all components
- [EKS Cluster](./examples/eks-cluster) - Kubernetes cluster with VPC
- [EC2 Instance](./examples/ec2-instance) - EC2 with security groups

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Run `terraform fmt` and `terraform validate`
4. Submit a pull request

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

## 👤 Author

**Ashwath Abraham Stephen**  
Senior DevOps Engineer | [LinkedIn](https://linkedin.com/in/ashwathstephen) | [GitHub](https://github.com/ashwathstephen)

