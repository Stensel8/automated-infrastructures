terraform {
  required_version = ">= 1.11.0"
}

resource "aws_security_group" "this" {
  name        = var.sg_name
  description = "Security group for ${var.sg_name}"
  vpc_id      = var.vpc_id

  # Ingress: Allow SSH (port 22)
  ingress {
    description = "Allow SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_cidrs
  }

  # Ingress: Allow HTTP (port 80)
  ingress {
    description = "Allow HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.http_cidrs
  }

  # Ingress: Allow HTTPS (port 443)
  ingress {
    description = "Allow HTTPS access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.https_cidrs
  }

  # Ingress: Allow all traffic within the VPC
  ingress {
    description = "Allow all internal VPC traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  # Egress: Allow all outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.sg_name
  }
}
