############################################
# AWS Provider Configuration
############################################

provider "aws" {
  profile = "default"         # AWS CLI profile to use
  region  = "us-east-1"       # Eastern region
}

terraform {
    backend "local" {}
}