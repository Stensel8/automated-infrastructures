variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 1
}

variable "ami_id" {
  description = "AMI ID to use for the EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "subnet_id" {
  description = "The subnet ID where the instances will be launched"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs to attach to the instances"
  type        = list(string)
}

variable "key_name" {
  description = "Name of the AWS key pair to use for SSH access"
  type        = string
}

variable "server_name" {
  description = "Base name for the EC2 instances"
  type        = string
}
output "public_ips" {
  description = "Public IP addresses of the created EC2 instances"
  value       = aws_instance.this[*].public_ip
}
