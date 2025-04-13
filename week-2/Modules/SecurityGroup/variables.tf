variable "sg_name" {
  description = "Name of the security group"
  type        = string
  default     = "default-sg"
}

variable "vpc_id" {
  description = "ID of the VPC where the security group will be created"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC used for internal communication"
  type        = string
  default     = "10.0.0.0/16"
}

variable "ssh_cidrs" {
  description = "List of CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "http_cidrs" {
  description = "List of CIDR blocks allowed for HTTP access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "https_cidrs" {
  description = "List of CIDR blocks allowed for HTTPS access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
