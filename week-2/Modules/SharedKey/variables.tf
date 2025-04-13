variable "key_name" {
  description = "Name of the AWS key pair to use for SSH access"
  type        = string
  default     = "awskey"
}

variable "public_key_path" {
  description = "Path to the public key file"
  type        = string
}
