terraform {
  required_version = ">= 1.11.0"
}

# This resource creates one or more EC2 instances based on the count provided
resource "aws_instance" "this" {
  count               = var.instance_count         # Number of instances to create
  ami                 = var.ami_id                 # The Amazon Machine Image (AMI) to use
  instance_type       = var.instance_type          # The instance type, e.g., t2.micro
  key_name = var.key_name                          # The name of the key pair to use for SSH access
  subnet_id           = var.subnet_id              # Subnet in which to launch the instance
  vpc_security_group_ids = var.security_group_ids  # List of security group IDs to attach

  # Assign a name tag for each instance using the base server_name and appending the instance number
  tags = {
    Name = "${var.server_name}-${count.index + 1}"
  }
}
