############################################
# General Settings
############################################

variable "aws_region" {
  description = "AWS region where the infrastructure will be deployed"
  type        = string
  default     = "us-east-1"
}

############################################
# Networking
############################################

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "vpc_name" {
  description = "Name for the VPC (used in tags)"
  type        = string
  default     = "klantA-prod-vpc"
}

############################################
# Compute
############################################

variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 3
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance (e.g., Amazon Linux 2023)"
  type        = string
  default     = "ami-00a929b66ed6e0de6"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "server_name" {
  description = "Base name for the EC2 instance(s)"
  type        = string
  default     = "klantA-prod-server"
}

############################################
# SSH / Key Pair
############################################

variable "user_home" {
  description = "The user's home directory (used to construct SSH key path)"
  type        = string
}

variable "ssh_key_name" {
  description = "The name of the public SSH key file"
  type        = string
  default     = "awskey.pub"
}

variable "public_key_path" {
  description = "Full path to the public SSH key used by the shared_key module"
  type        = string
}
