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

# NAT Gateway IDs
variable "nat_gateway_ids" {
  description = "The IDs of the NAT Gateways to use for the private subnets"
  type        = list(string)
}

# Whether to use a single NAT Gateway or multiple NAT Gateways for high availability
variable "use_single_nat_gateway" {
  description = "Whether to use a single NAT Gateway or multiple NAT Gateways for high availability."
  type        = bool
}