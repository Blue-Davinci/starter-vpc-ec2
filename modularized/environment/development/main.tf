provider "aws" {
  region = var.provider_region
}

# NAT Gateway Modularization
module "nat_gateway" {
  source = "../../modules/nat_gateway"

  # variables
  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids
  tags               = var.tags
}

# Networking Modularization
module "network" {
  source = "../../modules/network"

  # variables
  vpc_cidr                 = "10.0.0.0/16"
  tags                     = var.tags
  aws_public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  aws_private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
  aws_availability_zones   = ["us-east-1a", "us-east-1b"]
  nat_gateway_ids          = module.nat_gateway.nat_gateway_ids
}

# ALB 
module "alb" {
  source = "../../modules/alb"

  # variables
  alb_name            = "starter-vpc-ec2-alb-test"
  vpc_id              = module.network.vpc_id
  public_subnet       = module.network.public_subnet_ids
  enable_alb_deletion = false
  tags                = var.tags
}

# Compute plugin
module "compute" {
  source = "../../modules/compute"

  # VPC variables
  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids # Use the first public subnet for the instance

  # ALB variables
  alb_sg_id          = module.alb.alb_sg_id
  target_group_arn   = module.alb.target_group_arn
  target_tracking_resource_label = module.alb.target_tracking_resource_label

  # Instance variables
  ami                = var.instance_ami
  instance_ami       = var.instance_ami
  instance_type      = var.instance_type
  key_name           = null                              # Set to null to disable SSH access
  tags               = var.tags
}

# Monitoring
module "monitoring"{
  source = "../../modules/monitoring"

  target_group_arn_suffix = module.alb.target_group_arn_suffix
  asg_name = module.compute.asg_name
  alb_arn_suffix     = module.alb.alb_arn_suffix
  tags               = var.tags

  email_address = var.email_address
}