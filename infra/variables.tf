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
  default     = {
    Environment = "dev"
    Project     = "starter-vpc-ec2"
    Owner       = "blue"
  }
}

# VPC Variables
variable "vpc_cidr" {
    description = "The CIDR block for our VPC"
    type = string
    default = "10.0.0.0/16"
}