provider "aws" {
  region = var.provider_region
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
}

module "alb" {
  source = "../../modules/alb"

  # variables
  alb_name            = "starter-vpc-ec2-alb-test"
  vpc_id              = module.network.vpc_id
  public_subnet       = module.network.public_subnet_ids
  enable_alb_deletion = false
  tags                = var.tags
}

module "compute" {
  source = "../../modules/compute"

  # variables
  vpc_id            = module.network.vpc_id
  instance_ami      = var.instance_ami
  instance_type     = var.instance_type
  alb_sg_id         = module.alb.alb_sg_id
  private_subnet_id = module.network.private_subnet_ids[0] # Use the first public subnet for the instance
  key_name          = null                                 # Set to null to disable SSH access
  tags              = var.tags
}

# Create the bootstrap relationship between the ALB and EC2 instance
resource "aws_lb_target_group_attachment" "starter-vpc-ec2-tg-attachment" {
  target_group_arn = module.alb.target_group_arn
  target_id        = module.compute.ec2_instance_id
  port             = 80 # Port for HTTP traffic
}