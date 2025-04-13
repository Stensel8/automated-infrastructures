terraform {
  required_version = ">= 1.11.0"
}

resource "aws_key_pair" "shared_key" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}
