#!/bin/bash
# =====================================================
# Force Destroy Terraform Deployments for klantA
# This script navigates to both the test and prod
# Terraform directories and force destroys the infrastructure.
# Author: Stensel8
# =====================================================

set -euo pipefail

# Set the project root directory (update if needed)
PROJECT_ROOT="$HOME/automated-infrastructures"

# Terraform directories for test and prod environments
TERRAFORM_DIR_TEST="$PROJECT_ROOT/week-2/klantA/test"
TERRAFORM_DIR_PROD="$PROJECT_ROOT/week-2/klantA/prod"

echo "Force destroying Terraform deployment for TEST environment..."
cd "$TERRAFORM_DIR_TEST"
terraform destroy -auto-approve

echo "Force destroying Terraform deployment for PROD environment..."
cd "$TERRAFORM_DIR_PROD"
terraform destroy -auto-approve

echo "Terraform deployments for both TEST and PROD have been force destroyed."
