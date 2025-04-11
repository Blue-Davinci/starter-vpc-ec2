/*
    General variables that will be used across the project.
    These variables are used to configure the providers and the targs.
*/
variable "provider_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "starter-vpc-ec2"
    Owner       = "blue"
  }
}

# VPC Variables
variable "vpc_cidr" {
  description = "The CIDR block for our VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# public subnets CIDR blocks
variable "aws_public_subnet_cidrs" {
  description = "The CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}
# private subnets CIDR blocks
variable "aws_private_subnet_cidrs" {
  description = "values for the private subnets CIDR blocks"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

# availability zones
variable "aws_availability_zones" {
  description = "The availability zones to use for the subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# Key Name for ssh, will be disabled for now
variable "key_name" {
  description = "The name of the key pair to use for SSH access to the instances"
  type        = string
  default     = null # Set to null to disable SSH access
}

# EC2 type
variable "instance_type" {
  description = "The type of EC2 instance to launch"
  type        = string
  default     = "t2.micro"
}