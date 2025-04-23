# tags
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)  
}

# public subnet ids
variable "public_subnet_ids" {
  description = "A list of the public subnet IDs to launch the instance in"
  type        = list(string)
}

# private subnet ids
variable "private_subnet_ids" {
  description = "A list of the private subnet IDs to launch the instance in"
  type        = list(string)
}

# Whether to use a single NAT Gateway or multiple NAT Gateways for high availability
variable "use_single_nat_gateway" {
  description = "Whether to use a single NAT Gateway or multiple NAT Gateways for high availability."
  type        = bool
}