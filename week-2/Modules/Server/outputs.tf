# Output the IDs of the created EC2 instances
output "instance_ids" {
  description = "IDs of the created EC2 instances"
  value       = aws_instance.this[*].id
}

# Output the public IP addresses of the created EC2 instances
output "instance_public_ips" {
  description = "Public IP addresses of the created EC2 instances"
  value       = aws_instance.this[*].public_ip
}
