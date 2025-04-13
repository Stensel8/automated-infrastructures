############################################
# Terraform Outputs
############################################

output "vpc_id" {
  description = "The ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_id" {
  description = "The ID of the created public subnet"
  value       = module.vpc.public_subnet_id
}

output "server_instance_ids" {
  description = "The instance IDs of the created EC2 servers"
  value       = module.server.instance_ids
}

output "server_public_ips" {
  description = "The public IP addresses of the created EC2 servers"
  value       = module.server.public_ips
}
