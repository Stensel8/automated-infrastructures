############################################
# Week 1 - Basic Setup for klantA (Terraform)
############################################

# VPC
resource "aws_vpc" "klantA" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "klantA"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "klantA_igw" {
  vpc_id = aws_vpc.klantA.id

  tags = {
    Name = "klantA-igw"
  }
}

# Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.klantA.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "klantA-public-subnet"
  }
}

# Route Table & Association
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.klantA.id

  tags = {
    Name = "klantA-public-rt"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.klantA_igw.id
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Security Group
resource "aws_security_group" "klantA_sg" {
  name   = "klantA-sg"
  vpc_id = aws_vpc.klantA.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.klantA.cidr_block]
    description = "Allow internal VPC traffic"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = {
    Name = "klantA-sg"
  }
}

# Key Pair (upload your public key from local)
resource "aws_key_pair" "klantA_key" {
  key_name   = "klantA-key"
  public_key = file(var.public_key_path)
}

# EC2 Instance(s)
resource "aws_instance" "klantA_instance" {
  count = 1

  ami                         = "ami-00a929b66ed6e0de6" # Amazon Linux 2023 (x86_64)
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.klantA_sg.id]
  key_name                    = aws_key_pair.klantA_key.key_name
  associate_public_ip_address = true

  tags = {
    Name = "klantA-instance-${count.index + 1}"
  }
}
