# Call the VPC module
module "vpc" {
  source      = "../../Modules/VPC"
  vpc_cidr    = var.vpc_cidr
  subnet_cidr = var.subnet_cidr
  vpc_name    = var.vpc_name
}

# Call the SecurityGroup module
module "security_group" {
  source   = "../../Modules/SecurityGroup"
  sg_name  = "klantA-prod-sg"
  vpc_id   = module.vpc.vpc_id
  vpc_cidr = var.vpc_cidr
}

# Call the SharedKey module to use our own SSH key
module "shared_key" {
  source           = "../../Modules/SharedKey"
  key_name         = "awskey"
  public_key_path  = var.public_key_path
}

# Call the Server module to create an EC2 instance
module "server" {
  source             = "../../Modules/Server"
  instance_count     = var.instance_count
  ami_id             = var.ami_id
  instance_type      = var.instance_type
  subnet_id          = module.vpc.public_subnet_id
  security_group_ids = [module.security_group.sg_id]
  key_name           = module.shared_key.key_name
  server_name        = var.server_name
}

