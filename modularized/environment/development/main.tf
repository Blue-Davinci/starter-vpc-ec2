provider "aws" {
  region = var.provider_region
}

# Networking Modularization
module "network" {
  source = "../../modules/network"

  # variables
  vpc_cidr = "10.0.0.0/16"
  tags     = var.tags
  aws_public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  aws_private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
  aws_availability_zones = ["us-east-1a", "us-east-1b"]
}

module "compute" {
  source = "../../modules/compute"

  # variables
  vpc_id = module.network.vpc_id
  instance_ami = var.instance_ami
  instance_type = var.instance_type
  subnet_id = module.network.public_subnet_ids[0] # Use the first public subnet for the instance
  key_name = null # Set to null to disable SSH access
  tags = var.tags
}