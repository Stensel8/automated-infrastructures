############################################
# AWS Provider Configuration
############################################

provider "aws" {
  profile = "default"         # AWS CLI profile to use
  region  = var.aws_region    # Region is set via variables.tf or tfvars
}
