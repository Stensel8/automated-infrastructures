variable "vpc_cidr" {
  description = "CIDR-block voor de VPC"
  type        = string
}
variable "subnet_cidr" {
  description = "CIDR-block voor het publieke subnet"
  type        = string
}
variable "vpc_name" {
  description = "Naam voor de VPC (wordt gebruikt in tags)"
  type        = string
}
