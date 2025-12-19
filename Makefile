.PHONY: all init validate fmt fmt-check lint security test clean

MODULES := $(wildcard modules/*)
EXAMPLES := $(wildcard examples/*)

all: fmt validate lint security

# Initialize all modules
init:
	@echo "Initializing modules..."
	@for dir in $(MODULES); do \
		echo "  -> $$dir"; \
		cd $$dir && terraform init -backend=false > /dev/null 2>&1 && cd ../..; \
	done
	@echo "Initializing examples..."
	@for dir in $(EXAMPLES); do \
		echo "  -> $$dir"; \
		cd $$dir && terraform init -backend=false > /dev/null 2>&1 && cd ../..; \
	done

# Validate all Terraform
validate: init
	@echo "Validating modules..."
	@for dir in $(MODULES); do \
		echo "  -> $$dir"; \
		cd $$dir && terraform validate && cd ../..; \
	done
	@echo "Validating examples..."
	@for dir in $(EXAMPLES); do \
		echo "  -> $$dir"; \
		cd $$dir && terraform validate && cd ../..; \
	done

# Format Terraform files
fmt:
	@echo "Formatting Terraform files..."
	terraform fmt -recursive .

# Check formatting
fmt-check:
	@echo "Checking Terraform formatting..."
	terraform fmt -check -recursive .

# Run tflint
lint:
	@echo "Running tflint..."
	@for dir in $(MODULES); do \
		echo "  -> $$dir"; \
		cd $$dir && tflint --init > /dev/null 2>&1; tflint && cd ../..; \
	done

# Security scanning with tfsec
security:
	@echo "Running tfsec security scan..."
	tfsec . --minimum-severity MEDIUM

# Run checkov
checkov:
	@echo "Running Checkov..."
	checkov -d . --framework terraform --quiet

# Test specific module
test-vpc:
	@echo "Testing VPC module..."
	cd modules/vpc && terraform init -backend=false && terraform validate

test-eks:
	@echo "Testing EKS module..."
	cd modules/eks && terraform init -backend=false && terraform validate

test-ec2:
	@echo "Testing EC2 module..."
	cd modules/ec2 && terraform init -backend=false && terraform validate

test-iam:
	@echo "Testing IAM module..."
	cd modules/iam && terraform init -backend=false && terraform validate

test-s3:
	@echo "Testing S3 module..."
	cd modules/s3 && terraform init -backend=false && terraform validate

test-rds:
	@echo "Testing RDS module..."
	cd modules/rds && terraform init -backend=false && terraform validate

# Clean up
clean:
	@echo "Cleaning up..."
	find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name ".terraform.lock.hcl" -delete 2>/dev/null || true
	find . -type f -name "*.tfplan" -delete 2>/dev/null || true

# Generate documentation
docs:
	@echo "Generating documentation..."
	@for dir in $(MODULES); do \
		echo "  -> $$dir"; \
		cd $$dir && terraform-docs markdown . > README.md 2>/dev/null || true && cd ../..; \
	done

