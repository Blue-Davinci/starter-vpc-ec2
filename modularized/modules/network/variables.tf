# VPC Variables
variable "vpc_cidr" {
  description = "The CIDR block for our VPC"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}

# public subnets CIDR blocks
variable "aws_public_subnet_cidrs" {
  description = "The CIDR blocks for the public subnets"
  type        = list(string)
}
# private subnets CIDR blocks
variable "aws_private_subnet_cidrs" {
  description = "values for the private subnets CIDR blocks"
  type        = list(string)
}

# availability zones
variable "aws_availability_zones" {
  description = "The availability zones to use for the subnets"
  type        = list(string)
}
